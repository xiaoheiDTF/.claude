# Source-Analysis

> 来源: claudecn.com

# Source Analysis

**What actually happens when you type a message into Claude Code?**

Based on the `@anthropic-ai/claude-code` 2.1.88 npm release (since removed from npm history), reverse-engineered through source map → path statistics → semantic layering → cross-validation. Dissecting an industrial-grade agent harness system containing 1,902 source files, 43 tools, and 97 commands.

**Docs + Visual Map side by side.** Docs explain *why things are designed this way*; the [visual map](https://code.claudecn.com/) answers *where they are and how they connect*. Both share the same five-topic skeleton and data model. Open docs on one side, the visual map on the other.

## Start Here
[Research MethodConfirm capability boundaries first, then runtime skeleton, then transferable principles
](research-method/)[Engineering PlaybookTurn commands, tools, governance, plugins, and safeguards into an executable rollout path
](engineering-playbook/)[Architecture MapRead the package through six structural layers
](architecture/)[Runtime LoopFollow a request through seven stages from entry to rendering
](runtime/)[Tool PlaneUnderstand how 43 tools form the action surface across 6 groups
](tools/)[Command SurfaceUnderstand how 97 commands expose system capabilities across 7 groups
](commands/)[Signals & ExtensionsTrack MCP, skills, bridge, memory, and emerging surfaces
](signals/)

## Deep Dives
[Execution GovernanceRead permission mode, rules, hooks, and sandboxing as one boundary system
](governance/)[Memory SystemUnderstand long-session continuity through memdir, SessionMemory, and compact loops
](memory/)[Computer UseFrom CLI to desktop automation — executor, gates, host adaptation and MCP exposure
](computer-use/)[Plugin SystemInstallable extension lifecycle — install, uninstall, version control and runtime loading
](plugins/)[Cost Tracking7-dimension session metering — tokens, time, code changes, multi-model split and cost estimation
](cost-usage/)[Coordinator ModeFrom single agent to multi-Worker orchestration — four-phase workflow with independent verification
](coordinator/)[VoicePush-to-talk voice input — native audio, STT stream and OAuth gating
](voice/)[Hooks & ResilienceResilience subset of 80+ hooks — permission handling, session recovery, resource monitoring and exit safety
](hooks-resilience/)[MCP & BridgeTwo core channels — external tool capabilities and multi-surface connectivity
](mcp-bridge/)

## Reading Paths
Different backgrounds call for different entry points. Pick the path that fits your goals:

### Path 1: User Perspective

Understand *why* Claude Code behaves the way it does — why tools get denied, why long sessions compress, why some commands are hidden.

- Runtime Loop — follow a request through seven stages
- Execution Governance — understand the allow/deny decision chain
- Command Surface — find the internal mapping for commands you use
- Cost Tracking — understand token metering and compression triggers
### Path 2: Agent Builder

Extract reusable design patterns from an industrial-grade agent system — query loop, tool governance, context compaction, memory loops.

- Architecture Map — establish the six-layer structure
- Runtime Loop — understand the query loop heartbeat and state machine
- Tool Plane — understand tool registration, governance, and execution model
- Memory System — understand five-layer compression and long-session continuity
- Coordinator Mode — understand multi-Worker orchestration
### Path 3: Reverse Engineering Researcher

Fully map the system’s capability boundaries and evolution direction — from stable trunk to experimental edges.

- Architecture Map — reduce 1,902 files to six structural layers
- Tool Plane + Command Surface — full capability surface scan
- Signals & Extensions — identify mature vs. experimental capabilities
- All Deep Dive pages — verify source path evidence one by one
### General Advice

Regardless of path, use the [Visual Map](https://code.claudecn.com/) alongside the docs — docs explain *why things are designed this way*, the visual map answers *where they are and how they connect*.

## How to read this alongside official materials

Official materials are best for confirming feature definitions, supported boundaries, and minimal examples. The source-analysis section is better for understanding how the system is organized, why those constraints exist, and which patterns are worth carrying into your own agent engineering.

Recommended order:

- Use official docs to confirm capability primitives and current boundaries
- Read Research Method to establish the frame
- Then move into Runtime Loop and Tool Plane
- Use Engineering Playbook to reorganize those capabilities into a rollout path
- Finally treat Memory System, Coordinator Mode, and MCP & Bridge as transferable engineering samples
This avoids two common misreads: taking official minimal examples as complete system design, or treating local signals in a single source snapshot as long-term product commitments.

## Key Findings

Claude Code is not a simple LLM wrapper CLI. The 1,902 source files reverse-engineered from the source map reveal a carefully designed **agent harness system** — the model is just one unreliable component, surrounded by a complete outer-loop orchestration:

- query loop is the heartbeat: a while(true) loop (query.ts lines 241-1728) driving “sample → tool → permission → recover/continue/stop” cycles
- tools are managed interfaces, not bare functions: 43 tools registered through Tool.ts, each declaring readonly, concurrencySafe, sandboxed traits, passing through four governance layers before execution
- context is not unlimited: five-layer compression (Micro → TimeBased → APISide → SessionMemory → Full) triggers automatically at ~93% token threshold
- memory lives beyond transcripts: CLAUDE.md, memdir, SessionMemory, daily logs collectively maintain cross-session continuity
- security is not an add-on layer: permission modes, rule matching, hook interception, OS-level sandboxing are architecturally embedded in the execution path
- sub-agents are not “just another agent”: 6 built-in sub-agent types, each with independent toolsets and isolation strategies
## Four Runtime Invariants

Reading source by directory gives you a feature list. What actually holds the runtime together are four invariants that must hold simultaneously — understanding these matters more than understanding any single module:

| Invariant | What It Means | Maintained By |
| --- | --- | --- |
| **Trace topology must not break** | `tool_use` cannot dangle; thinking blocks cannot be cut at wrong boundaries; error recovery cannot expose half-formed state | `query.ts` recovery graph |
| **Cache prefix must not drift** | Once the model has seen content, its fate is frozen in subsequent turns; tool ordering and sub-agent prefixes all converge on this constraint | `toolResultStorage.ts` / `microCompact.ts` |
| **Capability surface must not open all at once** | Tools, MCP, skills are not pre-loaded — they’re exposed in layers, discovered lazily, activated by path/timing | `Tool.ts` / `ToolSearchTool` / `loadSkillsDir.ts` |
| **Continuity must not depend solely on transcript** | Stable continuity is distributed across CLAUDE.md, memdir, SessionMemory, daily logs, and other externalized artifacts | `attachments.ts` / `memdir/*` / `SessionMemory/*` |

The value of these invariants: **what’s worth migrating to your own agent design is not a specific function, but which invariant it’s paying for.**

## Lessons for Agent Builders

Claude Code’s source is not just a product implementation — it’s a reference sample for **Agent Harness Engineering**. Design principles you can directly adopt:

| Principle | Claude Code’s Practice | Source Evidence |
| --- | --- | --- |
| **Treat model as unreliable** | All tools default to `isReadOnly=false`, `isConcurrencySafe=false` | `src/Tool.ts` lines 362–480 |
| **Query loop is the heartbeat** | `while(true)` loop with 7 continue + 1 return exits | `src/query.ts` lines 307–1728 |
| **Tools are managed interfaces** | Permission mode → rule matching → hook interception → sandbox | `src/utils/permissions/` + `src/hooks/` + `src/utils/sandbox/` |
| **Context is working memory** | Five-layer compression (Micro → TimeBased → APISide → SessionMemory → Full) | `src/services/compact/` |
| **Error path is the main path** | prompt-too-long → auto compact → resume; max_tokens → retry with recovery count | `query.ts` `maxOutputTokensRecoveryCount` |
| **Verification must be independent** | Built-in `verificationAgent` — never let the implementer grade themselves | `src/tools/AgentTool/built-in/` |

### Cognitive Science in the Source

Claude Code’s design is not purely engineering — some decisions are deeply influenced by cognitive science (credited to Anthropic’s Character Lead, Amanda Askell):

- Memory filtering: The system doesn’t mechanically store all conversations; it only retains “surprising” information — the orienting response from cognitive science
- Avoiding learned helplessness: The system records both successes and failures, not just errors — preventing the AI from becoming overly cautious
- Progressive trust: New users start with restricted permissions that build up gradually — mirroring trust-building in human social interactions
## Visual Entry Points

The visual map at [code.claudecn.com](https://code.claudecn.com/) provides interactive structure diagrams, tool trait badges, Agent Loop animation, and global search. Each tool card shows `readonly` / `parallel-safe` / `sandboxed` / `deferred` interface trait labels — more intuitive than docs alone.

[Visual OverviewSnapshot scope, key stats, and project structure diagram
](https://code.claudecn.com/)[ArchitectureA structural map built from source map evidence
](https://code.claudecn.com/architecture/)[RuntimeA staged timeline of request execution
](https://code.claudecn.com/runtime/)[ToolsBrowse tools by capability group with interface trait badges
](https://code.claudecn.com/tools/)[CommandsBrowse commands by exposed surface
](https://code.claudecn.com/commands/)[SignalsInspect extension edges and code signals
](https://code.claudecn.com/features/)

## Evidence System

### Primary Evidence Sources

| Evidence | Purpose | Key Content |
| --- | --- | --- |
| `package.json` | Release boundary | Version 2.1.88, bin entry `cli.js`, Node ≥ 18 |
| `cli.js.map` | Source path index | 1,902 `../src/` user source files, 47 top-level modules |
| `sdk-tools.d.ts` | Tool contracts | Tool schema, input/output type definitions |
| `vendor/` | Cross-platform dependencies | ripgrep (code search), audio-capture (voice input) |

### Project Structure Diagram

```
claudecode/package → v2.1.88 → package.json → release boundary → README.md → product positioning → cli.js.map → 1,902 source paths → sdk-tools.d.ts → tool contracts → vendor/ → ripgrep + audio-capture → src/entrypoints + src/cli → entry routing → src/tools → 43 tool entities → src/commands → 97 command entries → src/services → service orchestration → src/components + src/ink → terminal UI → src/memdir + SessionMemory → memory and compression → src/skills + src/bridge → extension fabric
```

## Further Reading

- Claude Code Overview
- Visual Map
