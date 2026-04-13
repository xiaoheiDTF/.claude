# Claude-Code / Workflows / Quality-Gates

> 来源: claudecn.com

# Team Quality Gates: Plan → TDD → Build Fix → Review

When teams adopt Claude Code in day-to-day development, long-term success isn’t about one-off outputs—it’s about **control**: can you repeatedly ship correct, safe, rollbackable changes?

This is a team-executable loop (technology-stack agnostic): **plan first, implement with tests, fix build failures incrementally, then run security + quality review**.

## 0) Define “verification” upfront

Whether you use Claude Code or not, define verifiable checks first:

- unit tests: npm test / pnpm test / go test ./...
- build: npm run build / cargo build / make build
- E2E: npx playwright test
- key pages: a URL + critical interactions
## 1) Plan: pin requirements and risk

Two ways:

- lightweight: ask for a plan first; no code changes
- structured: use Plan Mode (see Plan Mode)
At minimum, the plan should include:

- restated requirements (alignment)
- risks (permissions, compatibility, migrations, performance)
- phased steps (each verifiable)
- rollback/degrade strategy (if relevant)
To enforce “plan before execute”, make `/plan` a project-level custom command (see [Custom commands](https://claudecn.com/en/docs/claude-code/advanced/custom-commands/)).

## 2) TDD: tests first, cover boundaries and error paths

You don’t need “80% coverage from day one”, but these two rules pay off:

- new features/bug fixes: write a reproducing test first, then implement
- critical paths: cover error handling and edge cases (nulls, limits, auth, outages)
A practical structure:

- unit tests: functions/components
- integration tests: API/DB/service interactions
- E2E (Playwright): key user journeys + evidence (screenshots/trace)
For a full E2E rollout (journey inventory, stability, artifacts, quarantine), see [E2E testing workflow](https://claudecn.com/en/docs/claude-code/workflows/e2e-testing/).

## 3) Build Fix: fix build failures incrementally

When build/typecheck fails:

- run once to collect all errors
- group by file/severity
- fix one error at a time
- rerun after each fix to avoid chain reactions
Many teams codify this as `/build-fix`: **fix one → rerun → verify**.

For “minimal diff troubleshooting”, see [Build troubleshooting](https://claudecn.com/en/docs/claude-code/workflows/build-troubleshooting/).

## 4) Review: block merge by severity

A pragmatic severity scheme:

- CRITICAL: must fix (secrets leakage, auth bypass, injection, path traversal, etc.)
- HIGH: should fix (major reliability issues, missing critical boundaries)
- MEDIUM: recommended (performance risks, maintainability)
- LOW: nice-to-have (style, naming)
Review checklist suggestions:

- secrets: any hardcoded tokens/keys?
- input validation: schemas/allowlists for external input?
- injections: SQL/command/template injection?
- XSS/CSRF: executable surfaces, CSRF protections?
- authorization: permission checks for sensitive ops?
- errors: sensitive info leakage?
Make review a fixed command (e.g. `/code-review`) and block merges when CRITICAL/HIGH exists.

For a reusable code review template, see [Code review workflow](https://claudecn.com/en/docs/claude-code/workflows/code-review/).
For security-sensitive changes, also run a security review: [Security review workflow](https://claudecn.com/en/docs/claude-code/workflows/security-review/).
For deleting code/deps, use a rollbackable path: [Safe dead-code cleanup](https://claudecn.com/en/docs/claude-code/workflows/refactor-clean/).

## 5) A recommended team loop (copyable)

- /plan or Plan Mode: agree on approach and verification
- /tdd: implement minimum with tests
- /build-fix: fix failures incrementally
- /code-review: severity-graded review and block risky changes
- pre-merge: run minimal verification set (tests + build + key E2E)
To operationalize it (folder structure, shared config, minimal file list), see [Team Starter Kit](https://claudecn.com/en/docs/claude-code/advanced/starter-kit/).

## Reference

- Related pages on this site:Team Starter Kit
