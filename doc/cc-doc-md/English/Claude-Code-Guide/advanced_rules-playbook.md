# Claude-Code / Advanced / Rules-Playbook

> 来源: claudecn.com

# Rules Playbook: Encode Team Bottom Lines

If you want Claude Code to be stable and controllable in a team, Rules often matter more than “tips”: they encode bottom lines for security, testing, code style, and Git workflow, reducing repeated correction.

This page presents a team-friendly structure for organizing rules (security, testing, style, Git workflow) so they can be reviewed and evolved over time.

## 1) Suggested rule split (start with 5 files)

Keep rules in small files so they can be reviewed and iterated:

- security.md: secrets, input validation, injection/XSS/CSRF bottom lines
- testing.md: TDD cadence and critical-path testing requirements
- coding-style.md: immutability, file structure, error handling, validation
- git-workflow.md: commit format, PR process, change scope
- performance.md: model selection, context window management, troubleshooting cadence
Tip: don’t start with “idealized” rules. Rules your team can actually follow are better than rules that only look impressive.

## 2) coding-style: immutability and organization (example)

Encode immutability as a hard rule:

```javascript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name
  return user
}

// CORRECT: Immutability
function updateUser(user, name) {
  return { ...user, name }
}
```

And add actionable structure guidelines:

- prefer many small files over a few huge ones (high cohesion, low coupling)
- keep functions small (e.g.
