# Source-Analysis / Architecture

> 来源: claudecn.com

# Architecture Map

This page answers one of the most fundamental yet easily misread questions: what layers make up the Claude Code system. Rather than presenting the raw directory tree, we reorganize the paths exposed by the release package into semantic structure layers that are easier to reason about.

**Treemap for a quick overview**: The [Architecture visualization](https://code.claudecn.com/architecture/) provides an interactive Treemap — area proportional to file count, colors distinguishing functional roles. Hover for details to instantly feel the code distribution.

**Two different counting methods on this page.** `47` comes from `../src/` top-level first-segment bucketing; the numbers inside the six layers (`33 / 216 / 510 / 222 / 46 / 24`) are semantic clustering path counts created for understanding — they are not physical directory-level counts.

## Analysis Target

- Version: @anthropic-ai/claude-code 2.1.88
- Source files: 1,902 user source files (from cli.js.map ../src/ paths)
- Top-level modules: 47 first-segment buckets (mix of directories and single-file entries)
## Primary Evidence

| Evidence | Purpose | Key Content |
| --- | --- | --- |
| `package.json` | Release boundary | Version 2.1.88, bin entry `cli.js`, Node ≥ 18 |
| `cli.js.map` | Source path recovery | 47 top-level modules under `../src/`, distribution and file counts |
| `sdk-tools.d.ts` | Tool layer verification | Tool schema, input/output type definitions |
| `vendor/` | Runtime capability identification | `ripgrep` (code search), `audio-capture` (voice input) |

## Six Layers

### Layer 1: Entry & Runtime Core (33 files)
Where the system truly starts. After CLI entry accepts the request, mode detection and environment initialization lead into the QueryEngine-driven main loop.

**Representative paths**:

- src/entrypoints/ — Entry routing: interactive REPL, single-shot -p, pipe mode, MCP server, SDK mode
- src/cli/ — CLI argument parsing, version check, fast-path dispatch
- src/query* — QueryEngine core: submitMessage() → query() → queryLoop(){ while(true) } main loop
- src/context.ts — Runtime context assembly: working directory, CLAUDE.md, token budget
**Core mechanism**: QueryEngine is the system’s heartbeat. It’s not a simple “send one request, wait for one result” — it’s a `while(true)` loop. After each API call, if the model returns tool calls, the loop continues; only when the model returns pure text (no tool calls) does it exit.

### Layer 2: Tooling & Governance (216 files)

Tools are not simple function collections but a governed capability surface with permissions, path constraints, execution modes, and external connectivity. This layer is what separates Claude Code from “a chatbox that can write shell commands.”

**Representative paths**:

- src/tools/ — 43 tool first-segment entities, including shared, testing, utils infrastructure buckets
- src/Tool.ts — Tool base class defining registration, schema declaration, execution interface, and output format
- src/utils/permissions/ — Permission loading and rule matching: 7 modes × 6 rule sources × 3 result types
- src/hooks/toolPermission/ — Pre-execution permission hook interception
- src/utils/sandbox/ — BashTool-exclusive sandbox: macOS sandbox-exec / Linux bubblewrap + seccomp
**Governance loop**: Tool call → Permission rule matching → Hook interception (PreToolUse) → Sandbox constraint (Bash only) → Execution → Hook callback (PostToolUse). Any layer can reject execution.

### Layer 3: UI & Terminal (510 files)

Users see a command line, but internally it’s far from “just output some text.” This is the largest layer by file count, driven by a React + Ink custom terminal rendering engine.

**Representative paths**:

- src/components/ — Terminal UI components: message rendering, status bar, dialogs, progress indicators
- src/ink/ — Custom Ink engine: ConcurrentRoot concurrent rendering, Yoga Flex layout, Cell compression
- src/keybindings/ — 17 keybinding contexts, 100+ default shortcuts
- src/vim/ — Complete Vim mode: Normal / Insert / Visual with motions + operators + text objects
- src/state/ — Global state management driving reactive UI updates
**Why this layer is heaviest**: Claude Code is not “backend agent plus a print layer.” The status bar shows model/mode/CWD/context/cost/Vim state in real time; @ file autocomplete, Deep Link protocol, and VS Code bridging all belong here.

### Layer 4: Extension Fabric (222 files)

This layer lets the system connect to external capabilities. MCP, skills, bridge, plugins, and hooks form an “extension fabric” that determines why Claude Code can continuously grow new capabilities.

**Representative paths**:

- src/services/mcp/ — MCP integration: 6 transports (stdio / SSE / HTTP / WebSocket / SDK / claude.ai proxy), 7 config scopes, OAuth 2.0 + PKCE
- src/skills/ — Skill system: SKILL.md format (YAML front matter + Markdown), 3-level progressive discovery (Discovery → Invocation → Fork)
- src/utils/plugins/ — Plugin system: 7 component types (commands / agents / skills / hooks / output-styles / MCP servers / LSP), 7 installation sources
- src/bridge/ — Cross-interface bridging: IDE / Desktop / Mobile / Chrome connections
- src/hooks/ — Hook system: 27 lifecycle events, 4 types (command / prompt / agent / HTTP)
**Extension depth**: MCP tools follow the `mcp__<server>__<tool>` naming pattern, dynamically registered into the tool system, sharing permission checks and execution paths with built-in tools.

### Layer 5: Memory & Recovery (46 files)

Whether long sessions can sustain depends not on how well the model answers once, but on how the system compresses, writes back, recovers, and inherits context.

**Representative paths**:

- src/services/compact/ — Five-layer compression: Micro → TimeBased → APISide → SessionMemory → Full
- src/services/SessionMemory/ — Session memory: post-compression structured summaries retaining files / skills / plan / hooks
- src/memdir/ — Memory directory: persistent storage, cross-session inheritance
- src/tasks/ — Task state management
- src/migrations/ — Data migration for cross-version format changes
**Compression trigger**: Automatic compression fires when token usage reaches ~93% of budget (effective-13K threshold). A 9-section summary template ensures post-compression context remains usable.

### Layer 6: Experimental Edge (24 files)

Some paths don’t necessarily belong to the current stable trunk, but they reveal directions the system is exploring.

**Representative paths**:

- src/buddy/ — Terminal pet system: deterministic gacha, ASCII animation engine, AI observer
- src/services/autoDream/ — Background memory consolidation: inter-session automatic dream processing
- src/services/teamMemorySync/ — Team memory sync: cross-member knowledge sharing
- src/services/voice/ + src/voice/ — Voice surface: voice input and commands
- src/remote/ — Remote control capabilities
- src/coordinator/ — Coordinator mode: Lead Agent task decomposition, parallel Workers
## Cross-Layer Dependencies

```
Entry & Runtime Core → 33 files → Tooling & Governance → 216 files → UI & Terminal → 510 files → Extension Fabric → 222 files → Memory & Recovery → 46 files → Experimental Edge → 24 files
```

Solid lines indicate trunk dependencies; dashed lines indicate experimental dependencies. Entry layer drives tooling and memory layers; tooling connects to extension fabric; UI observes runtime core; experimental edge connects to the trunk through extension fabric and memory.

## Memory & Recovery Layer: A Closer Look

Layer 5 is easiest to over-romanticize as a “magical memory system.” A more accurate reading: Claude Code separates **current session continuity, cross-session memory, compression recovery materials, and background consolidation** into different artifacts, each solving problems at different time scales.

### Four Continuity Artifact Types

| Type | Lifecycle | Key Path | Purpose |
| --- | --- | --- | --- |
| **Session Memory** | Current long session | `src/services/SessionMemory/` | Maintains structured working summaries, primarily serving compact and resume |
| **Memory Directory** | Cross-session | `src/memdir/` | Stores project, user, feedback, and reference persistent memories |
| **Compact Artifacts** | Around compression boundaries | `src/services/compact/`, `src/attachments.ts` | Re-injects critical materials after context compression to maintain continuity |
| **Background Consolidation** | Slow-cycle background | `src/services/autoDream/`, `src/services/teamMemorySync/` | Memory consolidation, merging, syncing, and slow-cycle governance |

The key insight: **don’t conflate long-session summaries, cross-session memory, and background consolidation into a single “memory” concept.**

### Five-Layer Compression Strategy

When token usage reaches ~93% of budget (effective-13K threshold), automatic compression triggers. Compression is not simple truncation but layered degradation:

- Micro Compaction — Remove redundant tool call results
- Time-Based — Compress earlier conversation by time decay
- API-Side — Leverage API prompt caching to reduce actual transmission
- SessionMemory — Compress into structured summaries using a 9-section template (files, skills, plan, hooks, etc.)
- Full Compaction — Full rewrite in extreme cases
The design insight: long-session agent stability depends not on model intelligence but on whether context governance and continuity artifact division are sufficiently fine-grained.

## Common Misreadings

- Misreading 1: commands is the system’s core → In reality, commands are more like the exposure layer; real capabilities are distributed across tools, services, and runtime
- Misreading 2: 510 UI files means the system is “frontend-heavy” → The UI layer’s complexity comes from a custom rendering engine (Ink ConcurrentRoot + Yoga layout + Cell compression + differential updates), which is a core competitive advantage for terminal agents
- Misreading 3: vendor/ is irrelevant → It shows the release package has hardened ripgrep (core code search) and audio-capture (voice entry) into the distribution layer
- Misreading 4: 24 experimental files mean the system is unstable → The 5 trunk layers total 1,027 files, all high confidence; the experimental layer is independent exploration
## Reading Order

- Runtime Loop — Switch from spatial to temporal perspective
- Tool Plane — See how capabilities are organized
- Execution Governance — Understand execution boundaries
- Signals & Extensions — See where the system is growing
