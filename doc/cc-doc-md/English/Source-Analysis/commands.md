# Source-Analysis / Commands

> 来源: claudecn.com

# Command Surface

This page answers “how users access Claude Code’s capabilities.” 97 command entries form the system’s operation surface — the user-facing facade of tool capabilities. Understanding the distinction between commands and tools is key to understanding this system.

Visual companion: [Commands page](https://code.claudecn.com/commands/)

**97 is the post-bucketing entry count.** This number comes from `../src/commands/` first-segment path normalization, excluding `createMovedToPluginCommand`, `init`, and `init-verifiers` (three internal wiring entries). It represents the “effective command entry surface,” not all slash commands visible to every user in every context.

## Command-Tool Relationship

```
Capability Surface → Orchestration → User Surface → Direct binding → Multi-tool → Service chain → Independent → User /command → Command router → src/commands/ → Single tool → Model selects tools → Service calls → Internal logic → Tool system → src/tools/
```

## Commands vs Tools

| Dimension | Commands | Tools |
| --- | --- | --- |
| Trigger | User types `/command` | Model decides to call |
| Count | 97 | 43 |
| Nature | User entry points | System capabilities |
| Permissions | Some require authentication | Unified permission layer |
| Location | `src/commands/` | `src/tools/` |
**Key insight**: Seeing a `/commit` command does not mean there’s a `CommitTool`. Commands are more like product entry points that orchestrate multiple tool capabilities together. Conversely, many tools (like `FileEditTool`) never need explicit user invocation — the model selects them automatically during the main loop.

## Command Overview

| Metric | Value |
| --- | --- |
| Total commands | 97 |
| Groups | 7 |
| Total files | 189 (including group-internal logic) |

## Seven Groups

### 1. Setup & Config (22 commands, 73 files)

Installation, authentication, model selection, plugin management, permission settings, and environment configuration.

| Command | Function |
| --- | --- |
| `/login` `/logout` | Authentication management |
| `/config` | Read/write configuration |
| `/model` | Switch model (Sonnet / Opus) |
| `/mcp` | MCP server management |
| `/permissions` | Permission rule management |
| `/plugin` `/reload-plugins` | Plugin install and reload |
| `/theme` | Terminal theme switching |
| `/upgrade` | Version upgrade |
| `/install` | System installation |
| `/install-github-app` | Install GitHub App |
| `/install-slack-app` | Install Slack App |
| `/terminalSetup` | Terminal configuration |
| `/add-dir` | Add working directory |
| `/remote-env` `/remote-setup` | Remote environment config |
| `/sandbox-toggle` | Sandbox on/off |
| `/privacy-settings` | Privacy settings |
| `/rate-limit-options` | Rate limit options |
| `/output-style` | Output style |
| `/oauth-refresh` | OAuth refresh |

### 2. Daily Workflow (23 commands, 44 files)

Day-to-day coding, session recovery, planning, summarization, and task advancement.

| Command | Function |
| --- | --- |
| `/plan` | Enter plan mode (analyze only, no execution) |
| `/compact` | Manual context compression |
| `/memory` | Memory management |
| `/resume` | Restore historical session |
| `/session` | Session management |
| `/summary` | Generate session summary |
| `/status` | View current status |
| `/tasks` | Task list |
| `/skills` | Skill management |
| `/files` | View related files |
| `/context` | Context information |
| `/usage` | Usage viewing |
| `/help` | Help information |
| `/copy` | Copy to clipboard |
| `/clear` | Clear context |
| `/exit` | Exit |
| `/brief` | Brief mode |
| `/hooks` | Hook management |
| `/onboarding` | New user guide |
| `/rewind` | Undo operations |
| `/share` | Share session |
| `/version` | Version info |
| `/voice` | Voice input |

### 3. Review & Git (10 commands, 18 files)

Branch management, commits, PRs, diffs, security reviews, and issue tracking.

| Command | Function |
| --- | --- |
| `/review` | Code review |
| `/commit` | Git commit |
| `/commit-push-pr` | Commit + push + create PR in one flow |
| `/diff` | View differences |
| `/branch` | Branch operations |
| `/issue` | Issue management |
| `/pr_comments` | PR comment handling |
| `/security-review` | Security review |
| `/autofix-pr` | Auto-fix PR |
| `/rename` | Rename |

### 4. Debugging & Diagnostics (18 commands, 26 files)

Problem diagnosis, metric observation, cache debugging, and internal tracing.

| Command | Function | Note |
| --- | --- | --- |
| `/doctor` | Environment diagnostics | Public |
| `/cost` | Cost viewing | Public |
| `/stats` | Usage statistics | Public |
| `/env` | Environment variables | Public |
| `/export` | Export data | Public |
| `/feedback` | Feedback | Public |
| `/release-notes` | Release notes | Public |
| `/ctx_viz` | Context visualization | Feature-flagged |
| `/debug-tool-call` | Tool call debugging | Feature-flagged |
| `/ant-trace` | Internal tracing | Feature-flagged |
| `/heapdump` | Heap memory snapshot | Feature-flagged |
| `/break-cache` | Cache breaking | Feature-flagged |
| `/mock-limits` | Simulate limits | Feature-flagged |
| `/reset-limits` | Reset limits | Feature-flagged |
| `/bughunter` | Bug hunter | Feature-flagged |
| `/passes` | Execution pass | Feature-flagged |
| `/perf-issue` | Performance issue | Feature-flagged |
| `/insights` | Insights panel | Feature-flagged |

### 5. Bridge & Remote (7 commands, 12 files)

IDE bridging, cross-device connection, and remote control.

| Command | Function |
| --- | --- |
| `/ide` | IDE integration (VS Code / JetBrains) |
| `/bridge` | Bridge control |
| `/bridge-kick` | Disconnect Bridge |
| `/desktop` | Desktop app connection |
| `/mobile` | Mobile connection |
| `/chrome` | Chrome extension connection |
| `/teleport` | Teleport |

### 6. Experimental Surface (13 commands, 24 files)

Product-surface exploration entries that reveal direction.

| Command | Function | Status |
| --- | --- | --- |
| `/ultraplan` | Long-duration planning (Opus-class model) | Feature-flagged |
| `/advisor` | AI advisor mode | Feature-flagged |
| `/thinkback` `/thinkback-play` | Thought retrospection and replay | Feature-flagged |
| `/fast` | Fast mode (switch to faster model) | Public |
| `/good-claude` | Positive feedback | Public |
| `/stickers` | Sticker system | Feature-flagged |
| `/statusline` | Status line config | Feature-flagged |
| `/btw` | By the way | Feature-flagged |
| `/color` | Color config | Public |
| `/effort` | Reasoning effort adjustment | Feature-flagged |
| `/extra-usage` | Extra usage tracking | Feature-flagged |
| `/tag` | Session tagging | Feature-flagged |

### 7. Agents & Extensions (4 commands, 7 files)

Sub-agent management, Vim mode, and internal migration commands.

| Command | Function |
| --- | --- |
| `/agents` | Sub-agent management |
| `/vim` | Vim mode toggle |
| `/keybindings` | Shortcut configuration |
| `/backfill-sessions` | Session data backfill (internal migration) |

## Command-to-Tool Mapping

Commands and tools are not one-to-one. A single command may orchestrate multiple tools, and a single tool may serve multiple commands. Here are the primary mapping relationships:

| Command | Underlying Tool / Execution Path | Mapping Type |
| --- | --- | --- |
| `/plan` | `EnterPlanModeTool` → `ExitPlanModeTool` | Direct binding |
| `/compact` | `src/services/compact/compact.ts` | Direct service call |
| `/memory` | `memdir/*`, `SessionMemory/*` | Service orchestration |
| `/resume` | `SessionMemory` + `setCostStateForRestore()` | Multi-service coordination |
| `/commit` | `BashTool` (git commands) + model orchestration | Tool + model |
| `/review` | `FileReadTool` + `GrepTool` + `AgentTool` (Verify) | Multi-tool orchestration |
| `/commit-push-pr` | `BashTool` × 3 (commit → push → gh pr create) | Tool chain |
| `/diff` | `BashTool` (git diff) | Single tool |
| `/voice` | `voice.ts` + `voiceStreamSTT.ts` → model input | Service chain |
| `/mcp` | `MCPTool` register/unregister + config write | Config + tool |
| `/plugin` | `PluginInstallationManager.ts` | Service call |
| `/agents` | `AgentTool` + `SendMessageTool` + `TaskStopTool` | Multi-tool |
| `/tasks` | `TaskCreateTool` / `TaskGetTool` / `TaskListTool` | Tool family |
| `/doctor` | Environment check scripts (bypasses tool system) | Independent path |
| `/cost` | `cost-tracker.ts` read | State read |
| `/vim` | `src/vim/` mode switching | UI layer |

**Reading this table**:

- “Direct binding” means 1:1 command-to-tool correspondence
- “Multi-tool orchestration” means the model automatically selects multiple tools based on context
- “Service chain” means the command triggers a sequence of service calls, not going through the standard tool system
- “Independent path” means the command entirely bypasses tools and model, executing internal logic directly
This also explains why the command count (97) far exceeds the tool count (43) — commands are user-facing product entries, tools are model-facing capability surfaces; the mapping between them is not linear.

## Feature-Flagged Commands

Of the 97 commands, a significant portion is controlled by feature flags and only appears under specific conditions. Their existence signals system evolution direction.

Key feature-flagged clusters:

- Diagnostic tools: ctx_viz, debug-tool-call, ant-trace, heapdump — internal debugging capabilities
- Experimental surface: ultraplan, advisor, thinkback — product direction exploration
- Remote connections: bridge, desktop, mobile — cross-interface extension
## Reading Order

- Tool Plane — Understand the capabilities behind commands
- Runtime Loop — See how commands enter the main loop
- Signals & Extensions — See the relationship between experimental commands and signals
