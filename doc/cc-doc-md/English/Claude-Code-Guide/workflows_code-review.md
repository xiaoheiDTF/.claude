# Claude-Code / Workflows / Code-Review

> 来源: claudecn.com

# Code Review Workflow: Severity Levels and Merge Gates

The goal of code review is not “nitpicking”—it’s turning risk into an explicit conclusion before merge: what must be fixed, what should be fixed, and what can be deferred. Two principles matter most: **review uncommitted changes**, and **grade by severity with hard blocking on high-risk issues**.

## 1) Scope: review “uncommitted changes”

The community workflow anchors on:

```text
Get changed files: git diff --name-only HEAD
```

This avoids missing accumulated changes by “only looking at the latest commit”.

## 2) Dimensions: security first, then quality and maintainability

Typical checkpoints include:

- Security (CRITICAL): hardcoded secrets, injection risks (SQL/XSS), vulnerable deps, path traversal, etc.
- Code quality (HIGH): overly large functions/files, deep nesting, missing error handling, console.log, TODO/FIXME
- Best practices (MEDIUM): mutable data hazards, accessibility, missing tests, etc.
## 3) Output format: location + issue + fix guidance

Standardize the output in your team:

- group by file
- each issue includes: severity, location, description, recommended fix
- the conclusion is explicit: block merge or not
## 4) Merge gate: CRITICAL/HIGH blocks merge

The rule is intentionally blunt:

```text
Block commit if CRITICAL or HIGH issues found
Never approve code with security vulnerabilities!
```

Operationalize it in your process (PR template or `CLAUDE.md`), and run it together with [Quality gates: Plan → TDD → Build Fix → Review](https://claudecn.com/en/docs/claude-code/workflows/quality-gates/).

## 5) Common pitfalls

- Focusing on style while ignoring input validation/auth boundaries
- Giving verdicts without fix paths (causes back-and-forth)
- Reviewing changes that are too large (split into smaller PRs)
## Reference

- Related pages on this site:Quality gates
- Security review
