# Cookbook / Agent-Patterns

> 来源: claudecn.com

# Agent Patterns & Claude Agent SDK

If you are learning agent systems from Cookbooks, it helps to read them in two passes:

- Start with workflow patterns so you can decide how work should be split, reviewed, and merged.
- Then move to runnable agent examples that add tools, permissions, hooks, and external systems.
## Recommended notebooks

### 1) Start with patterns
[Orchestrator-WorkersCoordinator + workers workflow
](orchestrator-workers/)[Evaluator-OptimizerQuality loop with evaluation
](evaluator-optimizer/)[Basic workflowsA few minimal multi-step patterns
](basic-workflows/)

### 2) Then move to the SDK examples
[One-liner research agentWebSearch + citations contract
](one-liner-research-agent/)[Chief of staff agentOutput styles, hooks, plan mode
](chief-of-staff-agent/)[Observability agent (MCP)Git/GitHub MCP servers + restrictions
](observability-agent-mcp/)

These examples can depend on external services such as MCP servers, GitHub tokens, or local scripts. Get your local environment working with one small example first, then expand step by step.

## How to read this section well

### 1) Start with workflow choices, not tooling choices
The most useful question at the beginning is rarely “which SDK feature should I use?” It is usually:

- Do I need one agent or multiple roles?
- Where should review happen?
- Which steps can run in parallel?
- What output contract must stay stable?
That is why the pattern pages come first: they help you settle the shape of the workflow before you add engineering details.

### 2) Then add operational details only where they matter

Once the workflow is stable, the SDK-oriented examples become more valuable. They show how to make the same workflow usable in a real team setting:

- narrow tool permissions
- stable output styles
- hooks and local automation
- MCP connections to external systems
### 3) Use these three examples as anchors

#### Minimal research loop

The research agent notebook shows two useful patterns:

- Minimal loop with allowed_tools=["WebSearch"]
- A system prompt that forces “sources as citations” and a dedicated “Sources:” section
It also demonstrates bumping `max_buffer_size` (example uses `10MB`) to handle larger artifacts (e.g., images).

#### Operational coordinator

The chief-of-staff example is useful when a team wants one agent to coordinate style, permissions, and execution rules in a more consistent way. The important details include:

- settings='{\"outputStyle\": \"executive\"}' (and a “technical” style example)
- setting_sources=["project"] to load output styles from .claude/output-styles/
- setting_sources=["project","local"] when you also need hooks from .claude/settings.local.json
One subtle but important point: `setting_sources` must include both `"project"` and `"local"` for hooks to load.

#### External system integration

The observability notebook is a concrete MCP wiring reference:

- Git MCP server via uv run python -m mcp_server_git --repository 
- GitHub MCP server via a Docker container (ghcr.io/github/github-mcp-server) with GITHUB_PERSONAL_ACCESS_TOKEN provided from GITHUB_TOKEN
It also calls out an important safety rule:

- disallowed_tools is required to actually restrict tool usage (e.g., prevent falling back to Bash).
## A practical reading order

- Use patterns to decide the workflow and feedback loop.
- Add Tool Use / PTC / compaction / memory as needed.
- Finish with engineering concerns: hooks, output styles, permissions, observability.
