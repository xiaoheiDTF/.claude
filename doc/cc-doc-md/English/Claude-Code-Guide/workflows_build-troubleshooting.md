# Claude-Code / Workflows / Build-Troubleshooting

> 来源: claudecn.com

# Build Troubleshooting: Incremental Fixes with Minimal Diffs

Build failures (TypeScript errors, missing deps, module resolution issues) usually go off the rails for two reasons:

- making too many changes at once (fix one, introduce three)
- “while we’re here” refactors (you end up right-but-unreviewable)
A reliable approach is simple: **make the smallest change that gets the build green again—no architecture adjustments**.

## 1) A reliable cadence: collect → categorize → fix one at a time

Recommended cadence:

- Run a full build/typecheck once and collect all errors (don’t stop at the first one).
- Categorize: inference/type errors / import errors / null/undefined / config issues / dependency conflicts.
- Prioritize by blocking impact: errors that break the build come first.
- Fix exactly one error, then rerun checks to ensure you didn’t trigger a chain reaction.
Teams often codify this as a command (like `/build-fix`): fix one → rerun → record progress.

## 2) Common “minimal diff” fixes (examples)

### Implicit any: add the smallest type annotation

```typescript
function add(x: number, y: number): number {
  return x + y
}
```

### null/undefined: handle the null path (prefer readability)

```typescript
const name = user?.name?.toUpperCase()
```

### Generic constraints: add a minimal constraint to T

```typescript
function getLength<T extends { length: number }>(item: T): number {
  return item.length
}
```

Principle: type assertions (`as ...`) are a last resort. Prefer explicit types/constraints/branches when possible.

## 3) When to stop “hard-fixing” and go back to design

Pause and switch back to planning when:

- you fixed the same error 2–3 times and it keeps returning
- the fix starts changing public API behavior (not just types)
- the root cause is a missing convention/config (path aliases, module boundaries, etc.)
At that point, switch to Plan Mode, agree on the config/convention change, then resume the incremental cadence (see [Plan Mode](https://claudecn.com/en/docs/claude-code/workflows/plan-mode/)).

## 4) Team rollout suggestions

- Add “how to handle build failures” to your team gates (see Quality gates).
- Put common commands into CLAUDE.md so people don’t keep re-explaining them.
- If you often run long commands, consider tmux + Hooks for reminders/records (see Session continuity & strategic compaction).
## Reference

- Related pages on this site:Plan Mode
- Quality gates
