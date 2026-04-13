# Claude-Code / Workflows / Session-Continuity

> 来源: claudecn.com

# Session Continuity and Strategic Compaction

Long sessions typically suffer from two issues:

- Context gets muddy: the longer you go, the more constraints get lost and drift increases.
- After an interruption, you can’t restart cleanly: you have to re-explain the background the next day.
Treat this as an engineering problem: use Hooks to create **traceable checkpoints**, and make compaction (compact) a **deliberate choice** rather than a random automatic event.

## 1) Strategic compaction: use compact at phase boundaries

Instead of waiting for auto-compaction to trigger at a random time, compact at points you control:

- after exploration/research, before you start editing
- after a milestone (a module is done and tests are green), before moving to the next
- when context is near full and the model starts forgetting/drifting (check /context first)
If your version supports `/compact` (or similar), treat it as a “phase transition” ritual.

## 2) Hook “pre-compaction markers”: PreCompact

A practical idea: on `PreCompact`, log “a compaction happened”, so later you can understand discontinuities in the record.

One implementation writes to `~/.claude/sessions/compaction-log.txt` and appends a marker to the most recent session file:

- hooks/memory-persistence/pre-compact.sh
The goal is not to copy scripts verbatim, but to make compaction explicit and traceable.

## 3) Session handoff via Hooks: SessionStart / SessionEnd

The pattern: at session end, write a daily handoff file (example `~/.claude/sessions/YYYY-MM-DD-session.tmp`) containing:

- current status (where you are)
- done/in-progress lists
- next minimal action
- which context files to load next time
If you don’t want scripts, you can maintain a `SCRATCH.md` or `SESSION.md` manually. Template:

```markdown
## Task headline (one sentence)

## Done
- ...

## Not done
- ...

## Next minimal action (executable)
- ...

## Verification (commands/pages/logs)
- ...

## Files to load next time
- `path/to/file`
```

## 4) Start with reminder Hooks, not blocking Hooks
Repos often use both reminder-style hooks (suggest tmux for long commands) and blocking hooks (`exit 1` to forbid risky actions). Team rollout advice:

- start with reminders (low friction)
- add validation hooks (console.log scans, format/typecheck)
- only then consider blockers (and document “why/how to bypass/who maintains it”)
## 5) A subtle footgun: counters must use a stable key

One script idea is “suggest compact after N tool calls” (`hooks/strategic-compact/suggest-compact.sh`). Watch out: if you use `$$` in temp file names, each run gets a different counter file, so the count never accumulates.

If you want accumulated reminders, use a stable key (fixed filename, or a stable session ID env var if your version provides one).

## Next steps

- learn hook events and config: see Hooks
- operationalize a minimal team setup: start from Team Starter Kit
## Reference

- Related pages on this site:Hooks
