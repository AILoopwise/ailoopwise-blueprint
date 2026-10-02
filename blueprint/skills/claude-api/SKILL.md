---
name: claude-api
description: "Guide for building applications with the Claude API, Anthropic SDK, or Agent SDK. Covers RAG pipelines, tool use, MCP servers, prompt caching, streaming, and extended thinking. Trigger on: imports anthropic, imports @anthropic-ai/sdk, imports claude_agent_sdk, 'build with Claude API', 'create MCP server', 'set up RAG', 'tool use pattern', 'Claude API app', 'Anthropic SDK', 'Agent SDK'. Do not use for: general programming (no Anthropic SDK involved), Claude Code configuration (use /onboarding or /new-project instead)."
---

# Claude API Development Guide

Perform a structured review of the user's API application code, or guide them through building one.

## Step 1: Identify Pattern
Determine which API pattern the user needs:
- **RAG pipeline** → See `references/rag-patterns.md`
- **Tool use / function calling** → See `references/tool-use-patterns.md`
- **MCP server/client** → See `references/mcp-patterns.md`
- **Prompt optimization** → Apply prompt engineering best practices
- **Multiple patterns** → Guide through each sequentially

## Step 2: Apply Best Practices
For any pattern, ensure:
- **Prompt caching** for repeated content (stable prefix, variable suffix)
- **Extended thinking** enabled for complex reasoning tasks
- **Error handling** with descriptive messages on all tool functions
- **Streaming** for user-facing responses
- **Temperature** set appropriately (0 for extraction, 0.5-0.7 for generation)
- **Message history** preserves full content blocks (including tool_use blocks)

## Step 3: Review Against Checklist
Load the relevant reference doc and validate the implementation against it:

### RAG Checklist
- [ ] Chunking strategy matches content structure (section-based for docs, sentence-based for articles)
- [ ] Embeddings use `input_type` parameter (`"document"` for indexing, `"query"` for search)
- [ ] Bulk embedding calls (not one-by-one) to avoid rate limits
- [ ] Hybrid retrieval (vector + BM25) with Reciprocal Rank Fusion
- [ ] Context window managed (don't exceed limits with retrieved chunks)

### Tool Use Checklist
- [ ] Tool descriptions are 3-4 sentences explaining when/why to use the tool
- [ ] All tool functions validate inputs and return descriptive errors
- [ ] `is_error: true` flag set on error tool results
- [ ] `tool_use_id` correctly matched in tool results
- [ ] Multi-turn loop: `while stop_reason == "tool_use"` pattern
- [ ] Assistant message content stored as full list (not just text)

### MCP Checklist
- [ ] Tools use typed parameters with `Field(description=...)` for auto-schema generation
- [ ] Resources use URI templates for parameterized access
- [ ] Error handling raises `ValueError` with descriptive messages
- [ ] Tested with `mcp dev` inspector before client integration

## Step 4: Implement and Iterate
Build or fix the implementation, then verify:
1. Run the code to confirm it works end-to-end
2. Test error paths (invalid inputs, missing data, API failures)
3. Check token usage and optimize if needed (caching, chunking)

## Evals
EVAL 1: Correct pattern (binary)
Question: Does the implementation use the right API pattern for the task?
Pass: Pattern matches the use case (RAG for document QA, tools for external data, MCP for service integration)
Fail: Wrong pattern chosen or patterns conflated

EVAL 2: Error handling (binary)
Question: Do all tool functions validate inputs and return descriptive error messages?
Pass: Every tool function has input validation and meaningful error messages
Fail: Any tool function silently fails or returns generic errors

EVAL 3: Implementation quality (model-graded)
Question: How well does the implementation follow Anthropic SDK best practices?
Grading prompt: "Analyze the code for: proper message history management, appropriate use of caching, correct tool schema structure, and clean error handling. List strengths and weaknesses. Score 1-10."
Pass threshold: >= 7
