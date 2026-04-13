# Source-Analysis / Tools

> 来源: claudecn.com

# Tool System

This page answers “what can Claude Code do” — and more importantly — “why it does it that way.” 43 tool entities form the system’s capability surface, organized with a unified governance layer, fail-safe defaults, and OS-level sandboxing.

**Docs + [ Visualization](#) side by side**: This document explains *why* things are designed this way. The [Tools visualization](https://code.claudecn.com/tools/) lets you click any tool card to verify source paths, parameters, and mechanics.

## Overview

| Metric | Value |
| --- | --- |
| Total tools | 43 |
| Groups | 6 |
| Governance files | 216 (permissions, hooks, sandbox) |
| Contract source | `sdk-tools.d.ts` (116KB type definitions) |

## Tool System Overview

```
Execution → Governance → Filtering → Model → LLM requests tool_use → Feature Flag → Deny Rules → MCP Merge → PermissionMode → Rule Matching → toolPermission Hook → Sandbox → StreamingToolExecutor → Read-only tools · parallel → Write tools · serial
```

## Core Design: Tool-First Architecture
Claude Code adopts a **Tool-First** architecture — the model never executes operations directly; it calls standardized tools. This is a deliberate engineering decision with major consequences:

| Traditional Hardcoded | Tool-First |
| --- | --- |
| Capabilities tightly coupled to AI logic | Each capability independently encapsulated |
| Adding features = modifying core code | Adding features = registering a new tool |
| Coarse-grained access control | Per-tool permissions, sandboxing, concurrency |
| Hard to test in isolation | Each tool independently unit-testable |
| Model sees a fixed function set | Model sees a dynamically computed tool set |

Source evidence: `src/Tool.ts` (tool base class) and `src/services/tools/toolOrchestration.ts` (orchestration layer).

## Tool Groups

### File Operations (8 tools, 32 files)

| Tool | Capability | Key Design |
| --- | --- | --- |
| `FileReadTool` | Read file content with line ranges | `maxResultSizeChars = Infinity` — no truncation |
| `FileWriteTool` | Write files, create or overwrite | Full replacement, no merge |
| `FileEditTool` | old_string/new_string surgical editing | Fails if old_string is not unique |
| `NotebookEditTool` | Jupyter notebook cell editing | Deferred loading |
| `GlobTool` | File pattern matching | readonly + parallel-safe |
| `GrepTool` | ripgrep-powered content search | readonly + parallel-safe |
| `ToolSearchTool` | Discover available tools | Only entry point for deferred tools |
| `BriefTool` | Switch to brief output mode | Render-stage tool |

### Execution & Shell (4 tools, 35 files)

| Tool | Capability | Security |
| --- | --- | --- |
| `BashTool` | Shell command execution | **Only sandboxed tool** — macOS sandbox-exec / Linux bubblewrap |
| `PowerShellTool` | Windows PowerShell | Same security model |
| `REPLTool` | Interactive REPL session | Deferred |
| `SleepTool` | Wait for duration | readonly |

#### BashTool: Four-Layer Security Deep Dive

BashTool has the most complex security design because it directly faces command injection risks:

- Layer 1 — Command Parsing: Extracts actual program names and arguments before execution
- Layer 2 — Pattern Matching: Built-in dangerous pattern library (rm -rf, fork bombs, Zsh bypass tricks)
- Layer 3 — Semantic Analysis: Understands intent (force push = destructive, echo $API_KEY = data leak)
- Layer 4 — OS-Level Sandbox: macOS sandbox-exec / Linux bubblewrap + seccomp, filesystem and network allow-lists
### Agents & Teams (5 tools, 36 files)

| Tool | Capability | Design |
| --- | --- | --- |
| `AgentTool` | Spawn sub-agents | 6 built-in agent types |
| `SendMessageTool` | Inter-agent messaging | UDS IPC |
| `TeamCreateTool` | Create persistent teams | Isolated git worktree |
| `TeamDeleteTool` | Remove teams | Destructive |
| `SkillTool` | Skill installation | SKILL.md from registry |

#### Sub-Agent Type System

| Type | Tools | Model | Design Metaphor |
| --- | --- | --- | --- |
| `Explore` | Read-only (Read, Glob, Grep, Bash) | Haiku (fastest) | **Scout** — light, fast |
| `Plan` | Read-only | Primary model | **Strategist** — observe only |
| `Verify` | Read-only | Primary model | **Auditor** — independent validation |
| `GeneralPurpose` | All | Primary model | **Full operator** |

Key isolation: each sub-agent gets its own ID, AbortController, and tool whitelist. Explore Agent sets `omitClaudeMd: true` to save tokens. Permission requests bubble up to the parent via `permissionMode: 'bubble'`.

### Planning & Workflows (13 tools, 44 files)

Plan mode, task management, cron scheduling, and worktree isolation.

### External Systems (10 tools, 33 files)

Web, MCP, LSP, and user interaction tools for bridging to external systems.

### Infrastructure (3 modules, 4 files)

Shared utilities, testing framework, and helper functions for the tool system.

## Unified Tool Contract

All tools register through a unified type defined in `Tool.ts`:

| Property | Default | Design Intent |
| --- | --- | --- |
| `isReadOnly()` | **`false`** | Assumes writes — fail-safe |
| `isConcurrencySafe()` | **`false`** | Assumes not parallel-safe — avoids races |
| `interruptBehavior()` | `block` | On new user message: cancel or wait |
| `maxResultSizeChars` | — | Oversize results persisted to disk |

**Key Philosophy**: All safety-related defaults are `false` (most restrictive). If a tool developer forgets to set a property, the system runs in the most conservative mode. Better slow than sorry.

## Three-Layer Tool Filtering

Tools are not all exposed to the model. Each query loop iteration filters the tool list:

- Feature Flag: isEnabled() === false → silently removed
- Permission Deny rules: Explicitly disabled tools removed before reaching the model
- MCP Merge: External MCP server tools dynamically merged
The filtered list is serialized as the `tools` parameter in the API request.

## Lessons for Agent Builders

| Principle | Claude Code Practice | Takeaway |
| --- | --- | --- |
| Default strictest | All safety properties default `false` | Start conservative, relax incrementally |
| Composable tools | Model freely combines tools | Design small-grained tools, let AI orchestrate |
| Dynamic tool set | Tool list computed per query | Adjust capabilities by context and permissions |
| Agent specialization | Explore uses fast model, Plan is read-only | Match model + permissions to task type |
| OS-level sandbox | Shell execution sandboxed | High-risk operations need isolation |
