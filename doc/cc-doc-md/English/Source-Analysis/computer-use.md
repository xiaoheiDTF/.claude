# Source-Analysis / Computer-Use

> 来源: claudecn.com

# Computer Use

From CLI to desktop automation — Claude Code builds a complete Computer Use subsystem through 15 dedicated files, bringing screen capture, mouse clicks, and [ keyboard](#) input into the agent capability surface.

## Core Question

How does a CLI tool running in a terminal safely gain the ability to “see the screen and operate the desktop”? Computer Use solves not just “can it click” but “who can click, where, and what happens when something goes wrong.”

## Subsystem Overview

| Metric | Value |
| --- | --- |
| **Dedicated files** | 15 |
| **Directory** | `src/utils/computerUse/` |
| **Maturity** | Integrated (merged into trunk) |
| **Subscription requirement** | Max / Pro users (internal employees bypass) |

## Architecture

| Component | File | Responsibility |
| --- | --- | --- |
| **Executor** | `executor.ts` | Wraps Rust (`@ant/computer-use-input`) and Swift native modules for mouse, keyboard, screenshots |
| **Gates** | `gates.ts` | GrowthBook remote config controlling feature switches (`tengu_malort_pedway`) |
| **Host Adapter** | `hostAdapter.ts` | CLI vs desktop adaptation — special handling for foreground window when running as terminal agent |
| **MCP Service** | `mcpServer.ts` | Exposes Computer Use capabilities as MCP Server for external consumers |
| **Cleanup** | `cleanup.ts` / `computerUseLock.ts` | Restores mouse/keyboard state on session end, prevents desktop control residuals |
| **Clipboard** | via `pbcopy`/`pbpaste` | No Electron dependency, direct system clipboard calls |

```
Exposure Layer → Safety Cleanup Layer → Executor Layer → Host Adaptation Layer → Gate Layer → GrowthBook Remote Config → tengu_malort_pedway → Subscription Check → Max / Pro / Ant → hostAdapter.ts → CLI vs Desktop → getTerminalBundleId() → Terminal Exclusion → Rust Native Module → Swift Native Module → Screenshots → Mouse Operations → Keyboard Input → computerUseLock.ts → Session Lock → cleanup.ts → State Restoration → mcpServer.ts → MCP Server
```

## Key Design Decisions

### Subscription Gate

`hasRequiredSubscription()` restricts Computer Use to Max/Pro users. Ant (internal employees) bypass the check. This is typical **progressive capability exposure** — high-risk capabilities open first to paying users and internal testers.

### Terminal Agent Mode

When CLI runs inside a terminal emulator, `getTerminalBundleId()` detects the hosting terminal app. Screenshots and clicks must exclude the terminal itself — otherwise the agent would capture its own command line or even click its own window.

### MCP Exposure

Computer Use is not only for Claude Code’s internal use but also exposed as an MCP Server via `mcpServer.ts`. External MCP clients can consume Computer Use capabilities, meaning desktop operations can be orchestrated into larger agent workflows.

### Session Lock and State Restoration

`computerUseLock.ts` implements session-level locking. When a Computer Use session is interrupted (user closes terminal, process crashes), `cleanup.ts` ensures mouse and keyboard state are restored to their original state, preventing desktop control residuals.

## Relationship to the Governance System

Computer Use is not a “superpower” that bypasses the permission system. It remains subject to the full four-layer governance:

- GrowthBook gate: Remote config can shut it down at any time
- Subscription check: Restricted by user tier
- Permission mode: Tool execution still passes through the standard permission chain
- Sandbox constraints: Computer Use capabilities are limited in sandboxed environments
## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Lazy native module loading** | Desktop operation native modules (Rust/Swift) load on first use, not at startup — avoiding ~8s cold start blocking |
| **Layered gates** | Remote config + subscription check + permission system — three independently controllable layers |
| **Host awareness** | An agent operating the desktop must know “where it is” — terminal exclusion is an easily overlooked but critical design point |
| **Safety cleanup** | Any agent capability that can alter external state needs a “session-end restoration” mechanism |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/utils/computerUse/` | Complete subsystem (15 files) |
| `src/utils/computerUse/executor.ts` | CLI executor implementation |
| `src/utils/computerUse/gates.ts` | Feature gates and remote config |
| `src/utils/computerUse/hostAdapter.ts` | Host adaptation layer |
| `src/utils/computerUse/mcpServer.ts` | MCP Server exposure |
| `src/utils/computerUse/cleanup.ts` | Safety cleanup |
| `src/utils/computerUse/computerUseLock.ts` | Session lock |

## Further Reading

- Architecture Map — Where Computer Use sits in the six-layer structure
- Tool Plane — How Computer Use integrates with tool governance
- Execution Governance — Gate and permission relationships
- Signals & Extensions — Computer Use maturity assessment
