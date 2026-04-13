# Claude-Code / Advanced / Config-As-Code

> 来源: claudecn.com

# Team Rollout: Treat Claude Code Config as Code

If you want Claude Code to be “stable and repeatable” in a team, the key isn’t memorizing more tips—it’s turning individual habits into a **versioned, reviewable, iterative** configuration system. This page presents a team-friendly structure you can adopt and evolve over time.

Principle: don’t copy configs blindly. Extract a **portable method**, then adapt fields/commands to your local version and official docs.

## The full picture: 7 configuration building blocks

In Claude Code, you can decompose “how we work” into these components (from hard constraints to softer guidance):

- CLAUDE.md: project memory and conventions (build/test/structure/style/no-go zones)
- rules/: non-negotiable rules (security, tests, code style, Git workflow)
- agents/: specialized subagents (planning, architecture, code review, troubleshooting, E2E)
- commands/: high-frequency slash commands (turn complex workflows into “one entrypoint”)
- skills/: reusable methodology and domain knowledge (TDD, backend/frontend patterns, standards)
- hooks/: automation guards at key events (PreToolUse/PostToolUse/Stop…)
- .mcp.json / MCP config: connect external tools into Claude Code’s toolchain
These can live in user scope `~/.claude/` (personal global defaults) and/or project scope `.claude/` (team-shared; recommended to version control).

If you want a minimal working template (directory layout + key files), start with: [Team Starter Kit](https://claudecn.com/en/docs/claude-code/advanced/starter-kit/).

If you want to codify reusable engineering patterns as Skills, see: [Skill Pattern Library](https://claudecn.com/en/docs/claude-code/advanced/skill-pattern-library/).

If you want to operationalize baseline “bottom lines” as Rules, see: [Rules playbook](https://claudecn.com/en/docs/claude-code/advanced/rules-playbook/).

## Recommended directory layout (team minimal)

Put team-shared config in the repo (example):

```text
your-repo/
├─ CLAUDE.md
└─ .claude/
   ├─ rules/
   │  ├─ security.md
   │  ├─ testing.md
   │  └─ coding-style.md
   ├─ agents/
   │  ├─ planner.md
   │  ├─ code-reviewer.md
   │  └─ build-error-resolver.md
   ├─ commands/
   │  ├─ plan.md
   │  ├─ code-review.md
   │  └─ build-fix.md
   ├─ hooks/
   │  └─ hooks.json
   └─ settings.json
```

Suggested rollout order: `CLAUDE.md` → `rules/` → `commands/` → `agents/` → `hooks/` → MCP.

## How to split config correctly: three rules of thumb

### 1) “Same across projects” goes to user scope; “project-specific” goes to project scope

Example: personal preferences (no emojis, prefer immutability, editor choice) belong in `~/.claude/CLAUDE.md`. Project facts (this repo uses pnpm; this is the test command) belong in the repo’s `CLAUDE.md`.

### 2) Use rules/ for bottom lines; use commands/ for workflows

`rules/` answers “what must be followed”; `commands/` answers “how we do common things”. Putting workflows into commands reduces onboarding cost significantly.

### 3) Give “brain-switching” work to agents

Typical “brain-switching” tasks: planning, architecture trade-offs, code review, security review, build troubleshooting, E2E design. Dedicated agents reduce main-thread context pollution and standardize outputs.

Agent files often include front matter metadata (example):

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and maintainability
tools: Read, Grep, Glob, Bash
model: opus
---
```

## Example: why a /plan command increases success rate
The community `/plan` pattern is: **restate requirements, assess risk, list steps, and ask for confirmation before touching code**. It’s a “hard constraint” that counters the default impulse to start editing too soon.

You can apply the same pattern to other high-risk actions:

- large refactors
- introducing new dependencies/services
- permission/security-related changes
## Why Hooks matter: turn lessons into automated guardrails

Common hook patterns:

- Reminder: suggest tmux for long-running commands to preserve logs
- Blocking: forbid risky operations with exit 1
- Consistency: auto-format, run type checks, warn on console.log after edits
- Session continuity: write session handoff files on SessionStart/Stop/PreCompact
Rollout tip: start with reminder/consistency hooks; add blockers only after team buy-in.

Hooks typically look like “event + matcher + hooks” (excerpt):

```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx|js|jsx)$\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Warn about console.log in edited files\n..."
    }
  ],
  "description": "Warn about console.log statements after edits"
}
```

## Performance and context: invest in reusable structure
From a team perspective, the most actionable performance lever is **context management**:

- put durable rules into CLAUDE.md / rules/ to reduce repeated explanations
- codify complex workflows as /command entrypoints
- use Plan Mode for complex work to fix scope and steps early
For session continuity and compaction as a workflow, see: [Session continuity & strategic compaction](https://claudecn.com/en/docs/claude-code/workflows/session-continuity/).

For keeping docs and architecture maps aligned, see: [Docs sync & codemaps](https://claudecn.com/en/docs/claude-code/workflows/docs-and-codemaps/).

## Reference

- Related pages on this site:Agent Skills
- Subagents
- Hooks
- Custom commands
