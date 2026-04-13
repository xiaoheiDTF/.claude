# Source-Analysis / Signals

> 来源: claudecn.com

# Signals & Extensions

This page answers “where is Claude Code heading.” 10 capability signals identified from path structures — not a marketing feature list but real system edges read directly from code. Classified into four maturity levels to avoid misreading prototypes as shipping features.

Visual companion: [Signals page](https://code.claudecn.com/features/)

## Maturity Assessment Criteria

| Level | Definition | Assessment Basis |
| --- | --- | --- |
| **Integrated** | Merged into the trunk | Has dedicated service/tool directory, command entry, and dependencies on other subsystems |
| **Emerging** | Taking shape | Has independent directory and service files, but command/UI not fully wired |
| **Partial** | Partially complete | Has directory and components, but appears as locally mounted capability from entry and dependency analysis |
| **Surface** | Surface-level signal | Only command entries or single files, not an independent subsystem |

## Signal Overview

Signals mature enough for independent topic pages have dedicated pages; the rest remain here as an observation index.

### Integrated (6 signals)

| Signal | Confidence | Description | Deep Dive |
| --- | --- | --- | --- |
| **Bridge & Mailbox** | High | Cross-interface connection with `bridge/` directory + `mailbox` context + multi-surface commands | [MCP & Bridge](https://claudecn.com/en/docs/source-analysis/mcp-bridge/) |
| **AutoDream & Memory Hygiene** | High | Background memory consolidation forming a closed loop with memdir and session memory | [Memory System](https://claudecn.com/en/docs/source-analysis/memory/) |
| **Cron & Remote Triggers** | High | `ScheduleCronTool` and `RemoteTriggerTool` provide scheduled and remote automation | [Tool Plane](https://claudecn.com/en/docs/source-analysis/tools/) |
| **Verification Agent Lane** | High | `AgentTool`’s `built-in/` includes verification, planning, and explore agents | [Coordinator](https://claudecn.com/en/docs/source-analysis/coordinator/) |
| **[ Computer](#) Use** | High | 15-file desktop automation subsystem | [Computer Use](https://claudecn.com/en/docs/source-analysis/computer-use/) |
| **Plugins** | High | ~1,700-line Schema installable extension system | [Plugin System](https://claudecn.com/en/docs/source-analysis/plugins/) |

### Emerging (3 signals)

| Signal | Confidence | Description | Deep Dive |
| --- | --- | --- | --- |
| **Team Memory Sync** | High | `teamMemorySync` service + `teamMemPaths` tool for cross-member memory sharing | [Memory System](https://claudecn.com/en/docs/source-analysis/memory/) |
| **Voice Surface** | Medium | Native audio + STT stream + OAuth gate, Push-to-talk voice input | [Voice](https://claudecn.com/en/docs/source-analysis/voice/) |
| **Coordinator Mode** | High | 369-line multi-Worker orchestration system with four-phase workflow | [Coordinator](https://claudecn.com/en/docs/source-analysis/coordinator/) |

### Partial (1 signal)

#### Buddy Companion

**Confidence**: Medium

The `buddy/` directory already has complete components (prompt, sprite, component — deterministic gacha, ASCII animation engine, AI observer), but from command entries it still appears as a locally mounted capability rather than a trunk feature.

**Path evidence**: `src/buddy/`

### Surface (3 signals)

#### Context Viz & Thinkback

**Confidence**: Medium

`ctx_viz`, `thinkback`, and `thinkback-play` expose research and retrospection surface entries — letting users visualize context distribution and replay thinking processes.

**Path evidence**: `src/commands/ctx_viz`, `src/commands/thinkback`, `src/commands/thinkback-play`

#### UltraPlan Overlay

**Confidence**: Medium

The `ultraplan` command appears alongside plan mode tools, potentially allowing planning sessions of up to 30 minutes on Opus-class models.

**Path evidence**: `src/commands/ultraplan`, `src/tools/EnterPlanModeTool/`, `src/tools/ExitPlanModeTool/`

#### Statusline Setup

**Confidence**: Medium

The `statusline` command and built-in `statuslineSetup` agent suggest the terminal status bar is treated as an independent product surface.

**Path evidence**: `src/commands/statusline`, `src/tools/AgentTool/built-in/statuslineSetup.ts`

## Signal Relationship Diagram

```
Partial → Emerging → Integrated → Surface → Context Viz → UltraPlan → Statusline Setup → Bridge & Mailbox → AutoDream → Cron & Triggers → Verification Agent → Computer Use → Plugins → Team Memory Sync → Voice Surface → Coordinator Mode → Buddy Companion
```

## How to Use These Signals

- Integrated signals have independent topic pages — click the Deep Dive links above for in-depth study
- Emerging signals are worth watching — the next version may bring significant changes
- Partial and Surface signals should not be over-interpreted — they may be deprecated or suddenly mature
## Reading Order

- Computer Use — Desktop automation subsystem
- Plugin System — Complete extension engineering
- Coordinator — Multi-Worker orchestration
- Voice — Voice input channel
- MCP & Bridge — Two core channels of the extension fabric
