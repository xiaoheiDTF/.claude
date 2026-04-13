# Claude-Code / Workflows / Advent-Of-Claude

> 来源: claudecn.com

# 31 High-Frequency Tips (Advent of Claude)

This is a one-page index of the most common (and most leverage) Claude Code tips, reorganized from beginner to advanced. Each item answers three questions: **what**, **when**, and **how**.

Note: features and shortcuts can change across versions. Treat your local `claude` `/help`, `/config`, and the official docs as the source of truth.

## 01–03｜Getting started & context

### 01) /init: let Claude “onboard” itself to the repo

- What: scans the repo and generates/updates CLAUDE.md, capturing build/test commands, structure, and conventions.
- When: first time in a new repo, after major tooling changes, or when you want a quick alignment before starting work.
- How: run /init, then keep writing team conventions back into CLAUDE.md.
- Read more: Context management / Basic usage
### 02) Update memory: write “spoken rules” into CLAUDE.md

- What: turn repeated preferences into durable project memory (package manager, test commands, style rules).
- When: you notice you keep correcting the same preference.
- How: explicitly ask Claude to “write this rule into CLAUDE.md”, or edit the file yourself.
- Read more: Context management
### 03) @ references: pull specific files/dirs into context

- What: reference a file or directory directly so Claude targets the right place.
- When: you’re working on a specific module and want to avoid “search the whole repo”.
- How: type @ and select a path from autocomplete (varies by terminal/IDE).
- Read more: Context management
## 04–08｜Must-know shortcuts (reduce friction)

### 04) ! prefix: run one-line Bash and bring output back

- What: quickly run git status, npm test, ls, etc., and inject the result into context.
- When: you want the result immediately instead of debating first.
- How: type !  (e.g. ! git status).
### 05) Esc Esc: rewind to a clean checkpoint

- What: rewind the conversation/changes to an earlier state—great for “try and revert”.
- When: you want a new approach without carrying wrong context forward.
- How: press Esc twice (note: already-executed terminal commands usually can’t be undone).
### 06) Ctrl+R: reverse-search prompt history

- What: search your previous prompts like shell reverse search.
- When: you have reusable “prompt patterns”.
- How: Ctrl+R to search, Ctrl+R again to cycle, Enter to use, Tab to edit first.
### 07) Ctrl+S: prompt stash

- What: stash an unfinished prompt so you don’t lose your train of thought.
- When: you’re halfway through a prompt and need to do a small side task.
- How: press Ctrl+S to stash, then come back and continue.
### 08) Tab / Enter: accept suggestions

- What: Claude Code may suggest next steps—Tab accepts (and lets you edit), Enter runs.
- When: you want to speed up “closing actions” (tests, commit messages, docs).
- How: when you see a grey suggestion, press Tab or Enter.
## 09–12｜Session management (treat context like a dev environment)

### 09) claude --continue: continue the last session

- What: restores the most recent session for this directory.
- When: you come back after a break and want to avoid re-explaining context.
- How: claude -c or claude --continue.
- Read more: Basic usage
### 10) claude --resume / /resume: pick a past session to resume

- What: choose from multiple historical sessions—useful for parallel projects.
- When: you’re working on multiple features/repos.
- How: claude --resume or /resume inside the session.
### 11) --teleport: move a web/mobile session to local (if supported)

- What: bring a session started on web/mobile into your local terminal.
- When: you started work on the go and want to continue at your desk.
- How: claude --teleport  (depends on your version).
### 12) /export: export the session to Markdown

- What: export the full session as Markdown for archiving and sharing.
- When: after a complex debugging/refactor you want a traceable record.
- How: run /export (exact UX depends on your version).
## 13–17｜Productivity features (visibility & editing ergonomics)

### 13) /vim: Vim editing mode for prompts (if supported)

- What: edit prompts with Vim-style keybindings.
- When: you write and revise long prompts in the terminal.
- How: toggle with /vim.
### 14) /statusline: customize the statusline (if supported)

- What: show branch/model/context usage at the bottom of the terminal.
- When: you want constant awareness of “where am I” and “how much context is left”.
- How: run /statusline and follow the prompts.
### 15) /context: see where tokens go (if supported)

- What: inspect context usage (system prompt, memory files, tool/server prompts, chat history, etc.).
- When: the model starts “forgetting” or drifting and you suspect context pressure.
- How: run /context.
### 16) /stats: usage stats dashboard (if supported)

- What: view usage trends and patterns.
- When: you want to measure habits and do an efficiency retrospective.
- How: run /stats.
### 17) /usage: quota/limits (if supported)

- What: check current usage and limits.
- When: you’re worried about being interrupted mid-task by quotas.
- How: run /usage (purchase/limits depend on product plans).
## 18–20｜Thinking & planning (think first, then change code)

### 18) ultrathink: allocate more reasoning for complex work

- What: trigger deeper reasoning (exact behavior varies by version/config).
- When: architecture, complex debugging, multi-factor refactors.
- How: prefix your prompt with ultrathink:.
- Read more: Plan Mode
### 19) Plan Mode: read-only analysis first

- What: analyze and plan without editing files.
- When: multi-file changes, unclear approach, or high security sensitivity.
- How: press Shift+Tab to switch to Plan Mode, or start with claude --permission-mode plan.
- Read more: Plan Mode
### 20) Extended Thinking (API): enable thinking in API calls

- What: enable extended thinking when building with the Claude API (exact fields depend on official SDK/docs).
- When: agent/toolchain development where deeper reasoning and explainability helps.
- How: enable thinking in API parameters (see official docs for examples).
## 21–23｜Permissions & safety (fast, but controlled)

### 21) /sandbox: put command execution behind a sandbox boundary

- What: set allow/deny boundaries once so Claude is interrupted less inside the safe region.
- When: you need to run tests/scripts frequently but want to reduce mistakes.
- How: run /sandbox, or configure sandboxing in settings.
- Read more: Security guide / Settings reference
### 22) --dangerously-skip-permissions: YOLO mode (careful)

- What: skip permission confirmations for speed—at significantly higher risk.
- When: isolated environments, short-lived containers, or when every step is predictable.
- How: claude --dangerously-skip-permissions.
- Read more: Security guide
### 23) Hooks: run checks/guards automatically at key moments

- What: trigger scripts on tool events (before/after tool use, permission requests, etc.) to enforce guardrails.
- When: you want to bake in style checks, dangerous command blocks, notifications, auditing.
- How: configure via /hooks or .claude/settings.json.
- Read more: Hooks
## 24–25｜Automation & CI/CD (put Claude in the pipeline)

### 24) -p Headless: scriptable CLI mode

- What: non-interactive execution—prints to stdout and exits; great for CI/batch jobs.
- When: auto-fix lint, summarize diffs, generate reports.
- How: claude -p "...", also works with pipes: git diff | claude -p "Explain these changes".
- Read more: Headless mode
### 25) Custom Commands: turn repeated prompts into reusable “slash commands”

- What: template and share common workflows.
- When: you keep typing the same prompt scaffolding every day.
- How: put Markdown files in .claude/commands/ (project) or ~/.claude/commands/ (global).
- Read more: Custom commands
## 26｜Browser integration (if supported)

### 26) Claude Code + Chrome: fix-and-verify in a real browser

- What: navigate pages, click, read console errors, take screenshots, and close the verification loop.
- When: you need to reproduce and verify in a real UI/web environment.
- How: install the browser extension per the official instructions.
## 27–31｜Agents & extensibility (upgrade personal habits into team productivity)

### 27) Subagents: split work across parallel specialists

- What: delegate “research/implementation/tests/docs” to different subagents in parallel.
- When: large refactors, cross-module debugging, multi-thread investigation.
- How: let Claude use Subagents, or explicitly ask to split and run tasks in parallel.
- Read more: Subagents
### 28) Agent Skills: package methodology into reusable capabilities

- What: bundle rules, scripts, and resources into reusable “skills” across projects.
- When: teams want consistent workflows (docs standards, release processes, runbooks).
- How: organize Skills as directories and load them via Claude Code.
- Read more: Agent Skills
### 29) Plugins: package commands/agents/hooks/MCP for distribution

- What: distribute an entire workflow as an installable package.
- When: you want “best practices” to be one install away for the team.
- How: follow the plugin spec and install per your setup.
- Read more: Plugins
### 30) LSP integration: IDE-grade code intelligence

- What: diagnostics, go-to-definition, find references, type info via LSP.
- When: large or strongly-typed codebases where feedback loops matter.
- How: configure an LSP server (usually requires installing the language server).
- Read more: Plugin reference (LSP)
### 31) Claude Agent SDK: build your own automation on the same loop

- What: reuse the agent loop/tool permissions/context patterns in your own programs.
- When: internal agents, automated reviews, docs generation pipelines.
- How: use the official SDK (refer to official docs for examples).
- Read more: SDK
## Next steps

- For a copy-paste command sheet: see Claude Code Quick Reference
- For a structured workflow: start from Workflows and Plan Mode
## Reference

- Advent of Claude: 31 Days of Claude Code (community)
