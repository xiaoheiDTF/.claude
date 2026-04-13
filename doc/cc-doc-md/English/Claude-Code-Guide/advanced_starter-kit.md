# Claude-Code / Advanced / Starter-Kit

> 来源: claudecn.com

# Team Starter Kit (Minimal Working Setup)

The hardest part of rolling out Claude Code in a team is rarely “missing features”—it’s **everyone having a different workflow**: some only describe verbally, some start editing immediately, some never run tests. The Starter Kit is a minimal setup that standardizes three essentials:

- clarify the problem first (Plan)
- make the change correctly (TDD/Build Fix)
- manage risk before merge (Code Review/Security)
This structure is designed for a practical team rollout: minimal files, clear boundaries, and easy iteration.

## Directory layout (commit to repo; shared across the team)

```text
your-repo/
├─ CLAUDE.md
└─ .claude/
   ├─ settings.json
   ├─ rules/
   │  ├─ security.md
   │  ├─ testing.md
   │  └─ coding-style.md
   ├─ agents/
   │  ├─ planner.md
   │  ├─ code-reviewer.md
   │  └─ build-error-resolver.md
   └─ commands/
      ├─ plan.md
      ├─ tdd.md
      ├─ build-fix.md
      └─ code-review.md
```

## 1) CLAUDE.md: write down project facts
This file is “project memory”. Keep it executable and verifiable:

```markdown
# Project overview
- Tech stack: …
- Entrypoints / structure: …

## Common commands (must be accurate)
- Install deps: …
- Run tests: …
- Build: …
- Lint/format/typecheck: …

## Constraints (team agreement)
- Default: analyze in Plan Mode before editing
- Any behavior change must add tests and/or docs
- Credentials/permissions changes require security review before merge
```

## 2) rules/: split bottom lines into small files
The community practice: break rules into reviewable chunks. Start with three:

- rules/security.md: secrets, input validation, least privilege
- rules/testing.md: TDD cadence, required coverage for critical paths
- rules/coding-style.md: file size, function size, error handling, etc.
Don’t paste “a huge idealized policy”. Write the checklist your team will actually follow.

## 3) agents/: delegate “brain-switching” tasks

Three common starter agents:

- planner: phased plan with risks/deps/acceptance criteria
- build-error-resolver: fix one build error at a time to avoid chain reactions
- code-reviewer: severity-graded security and quality review over uncommitted changes
Don’t build too many agents initially—locking in planning/troubleshooting/review yields immediate gains.

## 4) commands/: workflows as /plan, /tdd, /build-fix, /code-review

Command files are workflow templates. The key is **enforcing sequence**.

## Next steps

- Operationalize the loop: see Quality gates
- Turn team practices into reusable Skills: see Skill Pattern Library
