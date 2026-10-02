# Tool Use Implementation Patterns

Reference guide for building tool-using applications with the Claude API.

## Tool Schema Structure

Every tool needs `name`, `description`, and `input_schema`:

```python
tool_schema = {
    "name": "get_weather",
    "description": "Get current weather for a location. Returns temperature, "
                   "conditions, and humidity. Use when the user asks about "
                   "current weather conditions in a specific place.",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "City name or coordinates (e.g., 'San Francisco' or '37.7749,-122.4194')"
            },
            "units": {
                "type": "string",
                "description": "Temperature units",
                "enum": ["celsius", "fahrenheit"],
                "default": "celsius"
            }
        },
        "required": ["location"]
    }
}
```

**Description best practices:** Write 3-4 sentences. Tell Claude exactly when to use the tool, what it does, and what it returns. Good descriptions dramatically improve tool selection accuracy.

## Multi-Turn Tool Loop

The canonical agentic pattern — keep looping until Claude stops requesting tools:

```python
import anthropic
import json

client = anthropic.Anthropic()
MODEL = "claude-sonnet-5-5"  # current model ids: https://docs.claude.com/en/docs/about-claude/models

def chat(messages, tools, model=MODEL):
    return client.messages.create(
        model=model,
        max_tokens=4096,
        messages=messages,
        tools=tools,
    )

def run_conversation(messages, tools):
    while True:
        response = chat(messages, tools)

        # Store full content list (includes tool_use blocks) — required by API
        messages.append({"role": "assistant", "content": response.content})

        if response.stop_reason != "tool_use":
            break

        # Execute all requested tools
        tool_results = process_tool_calls(response)
        messages.append({"role": "user", "content": tool_results})

    return messages

def process_tool_calls(response):
    results = []
    for block in response.content:
        if block.type == "tool_use":
            try:
                output = execute_tool(block.name, block.input)
                results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": json.dumps(output),
                })
            except Exception as e:
                results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": f"Error: {e}",
                    "is_error": True,
                })
    return results
```

**Critical details:**
- `tool_use_id` must match `block.id` exactly
- Content must be a JSON string, not a raw Python object
- `is_error: True` feeds the error back to Claude so it can reason about failures
- Store `response.content` as the full list — never extract just the text

## Forcing Tool Use (Structured Extraction)

Force Claude to always call a specific tool — useful for guaranteed structured output:

```python
response = client.messages.create(
    model=MODEL,
    max_tokens=1024,
    messages=messages,
    tools=[extraction_schema],
    tool_choice={"type": "tool", "name": "extract_data"},
)

# The tool input IS your structured output
extracted = response.content[0].input  # dict matching your schema
```

**Use cases:** Entity extraction, classification, form filling, data normalization.

```python
extraction_schema = {
    "name": "save_article",
    "description": "Save extracted article metadata",
    "input_schema": {
        "type": "object",
        "properties": {
            "abstract": {"type": "string", "description": "One sentence summary"},
            "meta": {
                "type": "object",
                "properties": {
                    "word_count": {"type": "integer"},
                    "sentiment": {"type": "string", "enum": ["positive", "negative", "neutral"]},
                },
                "required": ["word_count", "sentiment"],
            },
        },
        "required": ["abstract", "meta"],
    },
}
```

## Batch Tool Pattern

Enable parallel tool execution by providing a wrapper tool:

```python
batch_tool_schema = {
    "name": "batch_tool",
    "description": "Invoke multiple tool calls simultaneously for efficiency. "
                   "Use when you need to call several independent tools at once.",
    "input_schema": {
        "type": "object",
        "properties": {
            "invocations": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string", "description": "Tool name to invoke"},
                        "arguments": {"type": "string", "description": "JSON-encoded arguments"},
                    },
                    "required": ["name", "arguments"],
                },
            }
        },
        "required": ["invocations"],
    },
}
```

Pass alongside the real tool schemas. Claude will use it when multiple independent tool calls can run in parallel.

## Streaming with Tools

```python
with client.messages.stream(
    model=MODEL,
    max_tokens=4096,
    messages=messages,
    tools=tools,
) as stream:
    for event in stream:
        if hasattr(event, 'type'):
            if event.type == "text":
                print(event.text, end="")
            elif event.type == "content_block_start" and event.content_block.type == "tool_use":
                print(f'\n>>> Tool Call: "{event.content_block.name}"')

    response = stream.get_final_message()
```

Use `stream.get_final_message()` after the loop to get the complete response for the tool processing loop.

## Built-in Tools

### Web Search
No tool result handling needed — Claude manages internally:
```python
web_search_tool = {
    "type": "web_search_20250305",
    "name": "web_search",
    "max_uses": 5,
    "allowed_domains": ["docs.anthropic.com"],  # optional
}
response = chat(messages, tools=[web_search_tool])
```

### Text Editor
Built-in `str_replace` tool for file editing:
```python
text_editor_tool = {
    "type": "text_editor_20250728",
    "name": "str_replace_based_edit_tool",
}
```
Commands: `view`, `str_replace`, `create`, `insert`, `undo_edit`.

## Best Practices Summary

1. **Write detailed tool descriptions** — 3-4 sentences explaining when/why/what
2. **Always handle errors** with `is_error: True` flag
3. **Store full content lists** in message history (not just text)
4. **Use `tool_choice`** for structured extraction workflows
5. **Use streaming** for user-facing responses with tools
6. **Validate tool inputs** before execution — don't trust Claude's inputs blindly
7. **Set temperature to 0** for tool-heavy workflows (deterministic tool selection)
