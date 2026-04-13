# Cookbook / Tool-Use

> 来源: claudecn.com

# Tool Use: From Tool Choice to PTC

The `tool_use/` directory is a set of practical “engineering recipes”: it ties tool schemas, loop patterns, and production concerns (cost, latency, safety) together.

## What you’ll get

- The core tool loop: tools definitions, tool_use / tool_result, multi-turn control
- Tool selection (tool choice) and how to reduce tool misuse
- Parallel tool calls, structured extraction, and reusable agentic workflow skeletons
- Advanced: PTC (programmatic tool calling), tool search for large toolsets, automatic context compaction
## The mental model: tool loop as a protocol

Most notebooks follow the same skeleton:

- You define tools (name + description + JSON-schema-ish input_schema).
- You call Claude with tools=... and some tool_choice.
- Claude either responds with text, or asks to call tools (stop_reason == "tool_use").
- Your app executes the tool(s) and sends results back as tool_result blocks that reference tool_use_id.
- Repeat until stop_reason == "end_turn".
## Minimal tool schema

Most examples rely on a JSON Schema-like `input_schema`:

```python
tools = [
  {
    "name": "print_sentiment_scores",
    "description": "Print sentiment scores of a given text.",
    "input_schema": {"type": "object", "properties": {"positive_score": {"type": "number"}}},
  }
]
```

## Returning results: tool_result and tool_use_id
When Claude emits a `tool_use` block, you send a matching `tool_result` that includes the `tool_use_id`.

This pattern is explicit in the parallel tool calls notebook:

```python
MESSAGES.append({"role": "assistant", "content": response.content})
MESSAGES.append(
  {"role": "user", "content": [{"type": "tool_result", "tool_use_id": last_tool_call.id, "content": result}]}
)
```

## Recommended notebooks

### 1) Start with a working tool loop
[Calculator toolA minimal tool loop example
](calculator-tool/)[Customer service agentClient-side tools + simulated tool results
](customer-service-agent/)[Extracting structured JSONUse tools to enforce structured outputs
](extracting-structured-json/)

### 2) Make tool use more controllable
[Tool choiceAuto / Any / Force a tool
](tool-choice/)[Parallel tool callsMultiple tool calls + batch tool pattern
](parallel-tools/)

#### Tool choice (Auto / Any / Force)
In `tool_use/tool_choice.ipynb`, the “auto” mode is shown as:

```python
tool_choice={"type": "auto"}
```

For production, the key is not just the parameter, but the prompt contract: clearly tell the model when it should use tools vs. answer directly.

#### Parallel tool calls + “batch tool” idea

`tool_use/parallel_tools.ipynb` demonstrates two practical patterns:

- Let the model call multiple tools in one turn (your app iterates response.content and handles each tool_use).
- Introduce a “batch tool” that can invoke multiple other tools to reduce turns.
### 3) Production-oriented patterns
[Programmatic tool calling (PTC)Code execution + allowed_callers
](ptc-programmatic-tool-calling/)[Tool search with embeddingsScale to hundreds/thousands of tools
](tool-search-with-embeddings/)[Automatic context compactiontool_runner + compaction_control
](automatic-context-compaction/)[Session memory compactionBackground memory + prompt caching
](session-memory-compaction/)[Memory & context managementLong-running agent memory patterns
](memory-and-context-management/)

#### PTC (Programmatic Tool Calling)
PTC is the “let code call tools” approach. In the PTC notebook:

- Traditional tool calling uses the beta endpoint with an explicit betas=[...] flag.
- The PTC setup adds a code execution tool and restricts which tools code is allowed to call:
```python
tool["allowed_callers"] = ["code_execution_20250825"]
ptc_tools.append({"type": "code_execution_20250825", "name": "code_execution"})
```

This is a useful pattern when you want Claude to generate code that orchestrates tool calls inside a controlled execution environment.

#### Tool Search with embeddings (when tools scale to hundreds/thousands)

The tool search notebook builds a “tool library”, embeds tools with SentenceTransformers, then selects tools by semantic similarity before calling them.

Note: the notebook uses `sentence-transformers/all-MiniLM-L6-v2` and will download the model on first use.

#### Automatic Context Compaction (keep long loops working)

`tool_use/automatic-context-compaction.ipynb` uses a beta `tool_runner` with:

```python
compaction_control={"enabled": True, "context_token_threshold": 5000}
```

This is the “long-running workflow” guardrail: keep the conversation moving without manual truncation, while retaining a summary message.

### 4) Vision + tools
[Using vision with toolsBase64 image input + structured extraction via tools
](vision-with-tools/)
In `vision_with_tools.ipynb`, image input is passed as base64 and the tool extracts structured fields (nutrition label example). It’s a good “multimodal + structured output” reference.

## Production notes

- Prefer auditable tools: validated inputs/outputs, failure handling, permissioning for side effects.
- Treat cost/latency as architecture: parallelism, caching, PTC, and compaction are tradeoffs you should measure.
- Keep notebook structure tests (make test-notebooks) in CI to maintain reproducibility.
