# Claude-Code / Workflows / Context-Roles

> 来源: claudecn.com

# Context Roles: Dev / Research / Review

Output quality in Claude Code depends heavily on the “role” you give the task. A practical pattern is to **explicitly switch roles by phase**, standardize the output structure, and reduce drift.

Below are three commonly used role templates (adapted from community config patterns). You can paste them into your chat as a “session preamble”.

## 1) Dev: ship a runnable version first

Use when:

- implementing features, fixing bugs, writing scripts, adding tests
- you want Claude to “land the change first, explain after”
Copy-paste prompt:

```text
Context: Dev mode
Goal: Implement the feature and make it verifiable
Behavior:
- Write code first, explain after
- After changes, run minimal verification (tests/build/scripts)
- Keep changes atomic; avoid unrelated refactors
```

## 2) Research: understand first, show evidence
Use when:

- exploring an unfamiliar codebase
- diagnosing a complex root cause
- you need evidence before conclusions
Copy-paste prompt:

```text
Context: Research mode
Goal: Understand before acting
Behavior:
- Read/search before concluding
- State clarifying questions and hypotheses first
- Validate hypotheses with evidence
Output order: Findings (evidence) → Inference → Recommendations
```

## 3) Review: actionable feedback by severity
Use when:

- PR review, quality review, security review
- you want a prioritized action list
Copy-paste prompt:

```text
Context: Review mode
Goal: Quality + Security + Maintainability
Behavior:
- Read through before commenting
- Sort by severity: CRITICAL > HIGH > MEDIUM > LOW
- Provide actionable fixes (not just problems)
Output: group by file + include locations
```

## When to switch roles
A stable cadence:

- unclear requirements / unfamiliar code: start in “Research”
- uncertain approach / broad impact: switch to Plan Mode (see Plan Mode)
- start implementing: switch to “Dev”
- ready to merge: switch to “Review”
To operationalize this (write into `CLAUDE.md`, codify as `/command`, or enforce via Hooks), start from [Team Starter Kit](https://claudecn.com/en/docs/claude-code/advanced/starter-kit/).

## Reference

- Related pages on this site:Team Starter Kit
