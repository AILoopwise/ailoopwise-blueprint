# MCP Implementation Patterns

Reference guide for building Model Context Protocol servers and clients.

## Architecture

```
Your App → MCP Client → MCP Server → [Tools / Resources / Prompts]
```

### Three Primitives

| Primitive | Controlled by | Purpose | Example |
|-----------|--------------|---------|---------|
| **Tools** | Model | Actions Claude decides to call | Calculate, API calls, file edits |
| **Resources** | Application | Data the app fetches proactively | Document listings, config, DB records |
| **Prompts** | User | Predefined workflows triggered by user | Slash commands, templates |

## When to Use MCP vs Direct Tools

**Use MCP when:**
- Integrating external services (GitHub, Slack, Jira, cloud providers)
- Building reusable tool servers shared across multiple apps
- The tool implementation lives in a separate process or language

**Use direct tools when:**
- App-specific logic tightly coupled to your application
- Simple one-off tool implementations
- Performance-critical paths (MCP adds IPC overhead)

## Defining Tools (Python MCP SDK)

The SDK auto-generates JSON schemas from typed parameters + `Field(description=...)`. No manual schema writing needed.

```python
from mcp import tool
from pydantic import Field

@mcp.tool
def read_doc_contents(
    doc_id: str = Field(description="The document ID to read")
) -> str:
    """Read the full contents of a document by its ID."""
    if doc_id not in docs:
        raise ValueError(f"Document {doc_id} not found")
    return docs[doc_id]

@mcp.tool
def edit_document(
    doc_id: str = Field(description="Document to edit"),
    old_string: str = Field(description="Text to find"),
    new_string: str = Field(description="Replacement text"),
) -> str:
    """Replace text in a document. The old_string must match exactly once."""
    if doc_id not in docs:
        raise ValueError(f"Document {doc_id} not found")
    if old_string not in docs[doc_id]:
        raise ValueError(f"'{old_string}' not found in document {doc_id}")
    docs[doc_id] = docs[doc_id].replace(old_string, new_string)
    return "Done"
```

**Best practices:**
- Use `Field(description=...)` for every parameter
- Raise `ValueError` with descriptive messages on all error paths
- Return strings (the SDK handles serialization)
- Add docstrings — they become the tool's description

## Defining Resources

Two types: static URI (list operation) and templated URI (fetch single item).

```python
@mcp.resource("docs://documents", mime_type="application/json")
def list_documents():
    """List all available document IDs."""
    return list(docs.keys())  # SDK auto-serializes

@mcp.resource("documents/{doc_id}", mime_type="text/plain")
def get_document(doc_id: str):
    """Fetch a single document by ID."""
    return docs.get(doc_id, "Not found")
```

URI parameters become function keyword arguments. Resources are for **read-only data exposure** — use tools for actions that modify state.

## Defining Prompts

Server-defined templates for common workflows, triggered by user action (slash commands):

```python
from mcp.server.fastmcp import FastMCP
from mcp.types import base

@mcp.prompt(name="format", description="Rewrites document in clean markdown")
def format_document(doc_id: str) -> list:
    """Format a document as clean markdown."""
    content = docs.get(doc_id, "")
    prompt_text = f"""Please reformat the following document in clean markdown.
Preserve all content but improve structure, headings, and formatting.

Document content:
{content}"""
    return [base.user_message(prompt_text)]
```

Prompts return a list of messages. The client triggers them via user actions (e.g., `/format`).

## MCP Client Implementation

```python
from mcp import ClientSession
from pydantic import AnyUrl

class MCPClient:
    def __init__(self):
        self.session = None

    async def connect(self, server_path):
        self.session = await ClientSession.connect(server_path)

    async def list_tools(self):
        result = await self.session.list_tools()
        return result.tools

    async def call_tool(self, tool_name, tool_input):
        return await self.session.call_tool(tool_name, tool_input)

    async def read_resource(self, uri):
        result = await self.session.read_resource(AnyUrl(uri))
        resource = result.contents[0]
        if resource.mime_type == "application/json":
            return json.loads(resource.text)
        return resource.text

    async def list_prompts(self):
        result = await self.session.list_prompts()
        return result.prompts

    async def get_prompt(self, name, arguments):
        result = await self.session.get_prompt(name, arguments)
        return result.messages
```

Wrap `ClientSession` in a class for proper resource cleanup (async context manager).

## Full Integration Flow

```
1. User sends query to your app
2. App calls client.list_tools() to get available tools
3. App sends query + tool schemas to Claude API
4. Claude returns tool_use block (e.g., "call read_doc_contents")
5. App calls client.call_tool("read_doc_contents", {"doc_id": "abc"})
6. MCP server executes the function
7. Result flows back through client to your app
8. App sends result back to Claude
9. Claude generates final response
```

The MCP client is a communication intermediary — it does not execute tools. The MCP server owns the execution.

## Testing with Inspector

```bash
mcp dev server.py
# Opens localhost browser UI for testing
```

Use the inspector to:
- List available tools and their schemas
- Input parameters manually and test execution
- Verify error handling works correctly
- Test before wiring up the full client

## Adding MCP Servers to Claude Code

```bash
# Add a server
claude mcp add [name] [command]

# Example: add GitHub's hosted MCP server (the npm package is deprecated)
claude mcp add --transport http github https://api.githubcopilot.com/mcp --header "Authorization: Bearer $GITHUB_TOKEN"

# Check MCP connections: type /mcp inside Claude Code, or start with debug logging
claude --debug
```

Configure in `.mcp.json` at project root:
```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_GITHUB_TOKEN_HERE"
      }
    }
  }
}
```

## Best Practices Summary

1. **Use `Field(description=...)`** on every tool parameter for auto-schema generation
2. **Raise descriptive errors** — `ValueError("Document X not found")` not `raise Exception()`
3. **Resources for reads, tools for writes** — resources expose data, tools perform actions
4. **Test with `mcp dev`** before client integration
5. **Use URI templates** for parameterized resource access
6. **Wrap client in a class** for proper async resource management
