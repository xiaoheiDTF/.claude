# Source-Analysis / Coordinator

> 来源: claudecn.com

# Coordinator Orchestration

From single agent to multi-Worker orchestration — `coordinatorMode.ts` (369 lines) reveals how Claude Code decomposes tasks through Lead Agent assignment, parallel Worker execution, and independent verification to build multi-agent workflows.

## Core Question

A single Agent Loop’s context window is a finite resource. When task scope exceeds what a single conversation can carry — e.g., “investigate bug root cause → fix → run tests → write PR” — the single agent either stuffs intermediate results and hits limits, or compresses and loses detail. The deeper problem: **a single agent cannot parallelize**, yet software engineering tasks are naturally suited for divide-and-conquer.

## Subsystem Overview

| Metric | Value |
| --- | --- |
| **Core file** | `coordinatorMode.ts` (369 lines) |
| **Directory** | `src/coordinator/` |
| **Maturity** | Emerging |
| **Activation** | Environment variable `CLAUDE_CODE_COORDINATOR_MODE` + Feature Flag `COORDINATOR_MODE` |

## Four-Phase Workflow

Coordinator Mode decomposes complex tasks into four ordered phases:

```
Research → Investigate → Synthesis → Consolidate → Implementation → Execute → Verification → Validate
```

| Phase | Description | Worker Characteristics |
| --- | --- | --- |
| **Research** | Investigate problems, gather context | Read-only, freely parallel |
| **Synthesis** | Consolidate research, form plans | Aggregation, typically serial |
| **Implementation** | Execute code changes per plan | Write operations, serial by file scope |
| **Verification** | Independently verify results | **No implementation context** |

### Independent Verification

The verification phase design is Coordinator’s most noteworthy decision: verification Workers do not carry implementation Worker context. This is intentional **forced independent perspective**. If the verifier sees the implementation reasoning chain, it’s more likely to be convinced “this should be right.” Independent verification requires reviewing results from scratch.

## Core Components

| Component | Responsibility |
| --- | --- |
| `isCoordinatorMode()` | Environment variable + Feature Flag dual check |
| `matchSessionMode()` | Auto-matches coordinator/normal mode on session restore, preventing mode drift |
| `getCoordinatorUserContext()` | Injects available tool lists, MCP server lists, and Scratchpad directory for Workers |
| `getCoordinatorSystemPrompt()` | 369-line complete System Prompt defining roles, tools, workflow, and Worker management protocol |

## Worker Management

```
AgentTool → AgentTool → SendMessageTool → TaskStopTool → Results → Results → AgentTool → AgentTool → Code changes → PASS/FAIL → Lead Agent → Coordinator → Worker 1 → Research → Worker 2 → Research → Worker 3 → Implementation → Worker 4 → Verification
```

Workers are managed through three tools:

| Tool | Responsibility |
| --- | --- |
| `AgentTool` | Spawn new Workers |
| `SendMessageTool` | Send messages/continue instructions to running Workers |
| `TaskStopTool` | Stop Workers |

### Parallelism Strategy

- Read-only tasks: Freely parallel (multiple Research Workers investigating different aspects simultaneously)
- Write operations: Serial by file scope (preventing two Workers from modifying the same file)
- Verification: Starts after all implementation completes, with independent context
### Scratchpad Sharing

A cross-Worker persistent directory controlled by the `tengu_scratch` Feature Flag. Workers can write intermediate results to Scratchpad, and other Workers can read them — the only explicit communication channel between Workers (besides Lead Agent forwarding).

## Relationship to Multi-Agent System

Claude Code provides three progressively complex multi-agent modes:

| Mode | Complexity | Context Inheritance | Use Case |
| --- | --- | --- | --- |
| **Sub-Agent** | Low | Fresh conversation | Single task delegation |
| **Fork** | Medium | Background execution | Parallel exploration |
| **Coordinator** | High | Worker isolation | Multi-phase workflow |

Coordinator is the heaviest mode — not simply “opening multiple agents” but a complete framework for task decomposition, assignment, execution, and verification.

### Difference from Teams

Coordinator Mode is in-process orchestration — all Workers run within the same Claude Code process. Teams are cross-process collaboration — multiple independent Claude Code instances communicating via UDS (Unix Domain Socket).

## Permission Handling

Coordinator mode has its own permission handler `coordinatorHandler.ts`, existing in parallel with the standard `interactiveHandler` (interactive confirmation) and `swarmWorkerHandler` (Worker mode). The runtime identity automatically selects the appropriate handler.

## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Independent verification** | Implementers and verifiers must have isolated context — don’t let implementers grade themselves |
| **Divide and parallelize** | Read-only tasks parallel, write operations serial — the minimal constraint for filesystem consistency |
| **Four-phase decomposition** | Research → Synthesis → Implementation → Verification is a general-purpose complex task processing paradigm |
| **Mode drift protection** | `matchSessionMode()` auto-matches mode on session restore, preventing coordinator sessions from resuming in normal mode |
| **Scratchpad communication** | Inter-Worker data exchange via filesystem rather than shared memory — simple but reliable |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/coordinator/coordinatorMode.ts` | Orchestration mode core (369 lines) |
| `src/tools/AgentTool/` | Worker generation and management (15 files) |
| `src/tools/SendMessageTool/` | Worker continuation communication |
| `src/tools/TaskStopTool/` | Worker stopping |
| `src/hooks/toolPermission/handlers/coordinatorHandler.ts` | Orchestration mode permission handler |

## Further Reading

- Tool Plane — AgentTool internals
- Execution Governance — Multi-mode permission handlers
- Signals & Extensions — Coordinator maturity assessment
- Memory System — Inter-Worker memory isolation
