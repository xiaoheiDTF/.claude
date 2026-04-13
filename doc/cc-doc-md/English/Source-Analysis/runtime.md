# Source-Analysis / Runtime

> 来源: claudecn.com

# Runtime Loop

If the architecture page is a spatial map, this page is a time map — tracking how a single request moves through Claude Code from entry to rendering.

Visual counterpart: [Runtime page](https://code.claudecn.com/runtime/)

## Core Question

After a request enters Claude Code, what stages does it pass through, where are boundaries tightened, and where are results compressed back into long-term context?

## Seven Main Stages

```
tool_use response → results flow back → Entry routing → Context assembly → Sampling & caching → Permission gate → Tool execution → Compression & write-back → Rendering & notification
```

| Stage | Description | Representative Paths |
| --- | --- | --- |
| Entry routing | Determines which entry path the current session takes | `src/entrypoints/`, `src/cli/` |
| Context assembly | Collects working directory, project conventions, memory, and token budget | `src/context.ts`, `src/utils/claudemd.ts`, `src/memdir/` |
| Sampling and caching | Calls the model, handles retry, caching, and rate limiting | `src/services/api/`, `src/services/rateLimit/` |
| Permission gate | Tightens shell, path, and tool permissions before execution | `src/utils/permissions/`, `src/hooks/toolPermission/` |
| Tool execution | Lets file, terminal, MCP, agent, and task entities participate in the main loop | `src/tools/`, `src/Tool.ts` |
| Compression and memory write-back | Maintains long-session sustainability, prevents context runaway | `src/services/compact/`, `src/services/SessionMemory/` |
| Rendering and notification | Converts runtime state into terminal UI, status bars, and notifications | `src/components/`, `src/ink/`, `src/hooks/notifs/` |

## queryLoop: The Core Heartbeat

The entire runtime’s heartbeat lives in `src/query.ts` lines 241-1728, the `queryLoop()` function. It’s not “call the model once and finish” — it’s a persistent `while(true)` loop. Each iteration:

- Destructures cross-iteration state: messages, toolUseContext, autoCompactTracking …
- Assembles system prompt + tool list (filtered through feature flags / deny rules / MCP merge)
- Calls the API (streaming response)
- Parses the response — pure text exits the loop; tool_use enters the tool execution path
- Tool execution: permission check → Hook → sandbox → parallel/serial execution → results flow back
- Checks compression threshold (~93% token budget), triggers compact if needed
- Appends tool results back to messages, continue into the next iteration
Cross-iteration state (the `State` object, lines 268-279) includes: `messages` (full conversation history), `toolUseContext` (tool execution context), `turnCount` (iteration counter), `maxOutputTokensRecoveryCount` (max_tokens retry), `hasAttemptedReactiveCompact` (reactive compression flag), and more. The loop has 7 `continue` exits and 1 `return` exit.

A single user request may trigger dozens of loop iterations — this is the fundamental reason Claude Code differs from ordinary chat tools.

## Two Critical Loops

### Execution Loop

Requests don’t terminate directly but cycle through “decide → tool execution → results flow back → decide again.” `StreamingToolExecutor` (`src/services/tools/StreamingToolExecutor.ts`) starts `isConcurrencySafe` tools in parallel as API responses stream in, while write-operation tools execute serially to avoid file conflicts.

### Memory Loop

Whether long tasks can sustain depends on whether the system can compress necessary information back into reusable state. `compact` (five-layer strategy: Micro → TimeBased → APISide → SessionMemory → Full), `SessionMemory` (9-section structured summary template), and `memdir` (cross-session persistence) together form this loop.

## Two Layers Worth Reading Separately

### Execution Governance

The most underestimated part of the runtime is not the tool system but the pre-execution governance. The source shows at least four types of evidence working together:

- src/types/permissions.ts and src/utils/permissions/PermissionMode.ts: type layer first defines permission modes and external behavior boundaries
- src/utils/permissions/permissions.ts, src/utils/permissions/permissionSetup.ts: merge rules with current context into actual enforceable boundaries
- src/hooks/toolPermission/: handle interactive, coordinator, and worker-side permission decisions before tool execution
- src/utils/sandbox/sandbox-adapter.ts: apply final execution constraints at the sandbox level, not just at the UI prompt level
This shows the “permission gate” is not a single function but a multi-segment chain from configuration, modes, rules, hooks to sandbox. See [Execution Governance](https://claudecn.com/en/docs/source-analysis/governance/) for the full breakdown.

### Memory Continuity

`compact` is not just token optimization. The source map directly shows this chain spanning multiple module groups:

- src/memdir/paths.ts, src/memdir/memdir.ts, src/memdir/findRelevantMemories.ts
- src/services/SessionMemory/sessionMemory.ts, src/services/SessionMemory/sessionMemoryUtils.ts
- src/services/compact/compact.ts, src/services/compact/sessionMemoryCompact.ts, src/services/compact/autoCompact.ts
Claude Code doesn’t “start fresh each turn” — it continuously loads memory, compresses history, preserves boundaries, and prepares context for the next turn. See [Memory System](https://claudecn.com/en/docs/source-analysis/memory/) for the full breakdown.

### Cost Tracking Layer

`src/cost-tracker.ts` (323 lines) is a cross-cutting concern spanning the entire runtime — 7-dimension session-level metering covering tokens, time, code changes, multi-model splits, and USD cost estimation. Implemented through `bootstrap/state.js` global state atoms, any module can read current session costs.

See [Cost Tracking](https://claudecn.com/en/docs/source-analysis/cost-usage/) for the full architecture analysis.

### Hooks and Runtime Resilience

The `src/hooks/` directory contains 80+ React hook files, many directly participating in runtime resilience — from permission decisions and session recovery to resource monitoring and exit safety. Error recovery doesn’t rely on a single mechanism but is distributed across four independent nodes: API-side retry, reactive compaction, permission degradation, and session persistence.

See [Hooks & Resilience](https://claudecn.com/en/docs/source-analysis/hooks-resilience/) for the full architecture analysis.

## Misreadings to Avoid

- Don’t treat commands as the runtime core. Commands are just the trigger surface.
- Don’t read compression as “a minor token-saving optimization.” It actually determines whether long sessions can continue.
- Don’t overlook the permission gate. Claude Code’s path to production-readiness largely depends on this layer.
## Further Reading

- Architecture Map
- Tool Plane
- Command Surface
- Execution Governance
- Memory System
