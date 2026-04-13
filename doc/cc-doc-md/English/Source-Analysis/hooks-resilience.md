# Source-Analysis / Hooks-Resilience

> 来源: claudecn.com

# Hooks & Resilience

A significant portion of the 80+ React hooks directly participate in runtime resilience — from permission decisions and session recovery to resource monitoring and exit safety, they form a distributed error recovery network across multiple nodes.

## Core Question

AI agent runtime resilience cannot rely on a single try/catch. When the API returns max_tokens, when context exceeds limits, when the terminal loses focus, when the IDE connection drops — the system needs recovery capability at multiple independent nodes simultaneously, rather than centralized exception handling.

## Resilience Categories

| Category | Representative Hook | Resilience Responsibility |
| --- | --- | --- |
| **Permission decisions** | `toolPermission/handlers/` | Three parallel handlers: `interactiveHandler` (interactive confirmation), `coordinatorHandler` (orchestration mode), `swarmWorkerHandler` (Worker mode) — selected by runtime identity |
| **Session recovery** | `useSessionBackgrounding.ts` | Detects terminal defocus/backgrounding, triggers session save and restore |
| **Connection health** | `useIdeConnectionStatus.ts`, `useDirectConnect.ts` | Degradation path when IDE connection drops |
| **Resource monitoring** | `useMemoryUsage.ts`, `useTerminalSize.ts` | Real-time response to memory pressure and terminal size changes |
| **Task watching** | `useScheduledTasks.ts`, `useTaskListWatcher.ts` | Background task status polling and anomaly notification |
| **Exit safety** | `useExitOnCtrlCD.ts` | Prevents state loss from accidental exit |

## Distributed Recovery Architecture

```
Any node failure → Other nodes still operational → Independent recovery → Resource-Side Monitoring → useMemoryUsage → Memory pressure → useTerminalSize → Terminal size → useExitOnCtrlCD → Exit safety → Session-Side Persistence → useSessionBackgrounding → Terminal backgrounding → useIdeConnectionStatus → IDE connection health → Permission-Side Degradation → interactiveHandler → Interactive confirmation → coordinatorHandler → Orchestration mode → swarmWorkerHandler → Worker mode → API-Side Recovery → max_tokens retry → maxOutputTokensRecoveryCount → max 3 attempts → Reactive compaction → hasAttemptedReactiveCompact
```

**Core design**: Four recovery nodes are mutually independent. API-side retry failure doesn’t affect session persistence; permission degradation doesn’t affect resource monitoring; any single node failure still allows other nodes to maintain basic system operation.

## Key Recovery Mechanisms

### API-Side: max_tokens Recovery

When the API returns `max_tokens` (model output truncated), `queryLoop` controls retry via `maxOutputTokensRecoveryCount`. Maximum 3 retries then gives up — this is a **circuit breaker** pattern preventing infinite retry token burn.

### API-Side: Reactive Compaction

When context approaches the budget ceiling, `hasAttemptedReactiveCompact` ensures reactive compaction is tried only once. If still over-limit after compaction, the system enters a more aggressive recovery path (dropping the oldest API turn groups).

### Permission-Side: Three Handler Types

Permission decisions are not a single function but select different handlers based on runtime identity:

- Interactive: Shows confirmation dialog, waits for user decision
- Orchestration mode: Lead Agent makes permission decisions on behalf of the user
- Worker mode: Worker permissions are preset by the Lead Agent
### Session-Side: Backgrounding Protection

`useSessionBackgrounding` detects terminal defocus (user switches to another window) or entering background. Once triggered, it automatically saves session state, ensuring that even if the process is killed by the OS, the next launch can recover.

### Exit-Side: Cascading Timeout

`useExitOnCtrlCD` is not a simple `process.exit()`. The exit flow is cascading:

- Terminal UI cleanup
- Running tool interruption
- Hook callbacks (SessionEnd, 1.5-second timeout)
- Telemetry data drain
- 5-second failsafe — if above steps hang, force exit
## Hook System Overview

Claude Code’s Hooks are not just UI state management — 26 event types cover the complete lifecycle from session start to tool execution to session end:

| Event Group | Representative Events | Purpose |
| --- | --- | --- |
| **Tool execution** | `PreToolUse`, `PostToolUse`, `PostToolUseFailure` | Pre/post tool execution interception |
| **Permissions** | `PermissionRequest`, `PermissionDenied` | Permission decision hook points |
| **Session** | `SessionStart`, `SessionEnd` | Session lifecycle |
| **User interaction** | `UserPromptSubmit`, `Stop` | User input and stop signals |
| **File changes** | `FileChanged` | Filesystem change notifications |

### Hook Execution Model

- Async generators: Hook callbacks execute via async generators
- Timeout protection: Default 10 minutes; SessionEnd is 1.5 seconds
- Trust gating: In interactive mode, all hooks require trust dialog confirmation
- Exit code semantics: 0 = allow, 2 = blocking error (enqueued as task notification)
## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Distributed recovery** | Don’t put all exception handling in one try/catch — set recovery points at API, permission, session, and resource layers |
| **Circuit breaker** | Retries must have limits (max_tokens max 3), preventing runaway loops from burning resources |
| **Cascading exit** | Exit is not `process.exit(0)` but orderly cleanup — with a “last resort” timeout |
| **Backgrounding protection** | Agent processes can be killed by the OS at any time; session state needs continuous saving, not just write-on-exit |
| **Identity awareness** | The same permission decision follows completely different paths depending on runtime identity (interactive/orchestration/Worker) |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/hooks/toolPermission/handlers/` | Three permission handlers |
| `src/hooks/useSessionBackgrounding.ts` | Session backgrounding |
| `src/hooks/useIdeConnectionStatus.ts` | IDE connection health |
| `src/hooks/useMemoryUsage.ts` | Memory monitoring |
| `src/hooks/useScheduledTasks.ts` | Task scheduling |
| `src/hooks/useExitOnCtrlCD.ts` | Exit safety |
| `src/query.ts` lines 268-279 | Cross-iteration recovery state |

## Further Reading

- Runtime Loop — Where hooks sit in queryLoop
- Execution Governance — Full permission handler chain
- Memory System — Session recovery and memory persistence
