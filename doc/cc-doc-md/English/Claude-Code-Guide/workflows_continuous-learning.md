# Claude-Code / Workflows / Continuous-Learning

> 来源: claudecn.com

# Continuous Learning: Turn Session Retros into Skills

Many valuable “engineering insights” don’t show up in the final code—they live in the process: how you debugged, how you decomposed the task, what workaround you discovered. A practical pattern is to trigger a lightweight retrospective at session end and save reusable patterns into local Skills (e.g. `~/.claude/skills/learned/`).

This is not built into Claude Code by default; it’s an engineering pattern implemented via Hooks.

## 1) Why use a Stop Hook (instead of analyzing every message)

The rationale is straightforward:

- Stop triggers once at the end—low overhead
- analyzing every message adds latency and pollutes context
## 2) Minimal implementation: only prompt for extraction above a threshold

The example script reads the transcript from `CLAUDE_TRANSCRIPT_PATH` and filters out short sessions (e.g., skip if fewer than 10 user messages):

```bash
transcript_path="${CLAUDE_TRANSCRIPT_PATH:-}"
message_count=$(grep -c '\"type\":\"user\"' \"$transcript_path\" 2>/dev/null || echo \"0\")
```

If the threshold is met, it prints lightweight prompts (excerpt):

```text
[ContinuousLearning] Session has N messages - evaluate for extractable patterns
[ContinuousLearning] Save learned skills to: ~/.claude/skills/learned
```

The key design choice: **prompt humans to review**, rather than auto-generating unchecked “rules”.

## 3) Config suggestion: define what to extract vs. ignore

The example `config.json` defines two lists:

- patterns_to_detect: e.g. error_resolution, workarounds, debugging_techniques, project_specific
- ignore_patterns: e.g. simple_typos, one_time_fixes
This helps avoid turning one-off fixes into long-term rules.

## 4) Security & privacy (important for teams)

Transcripts often include:

- code snippets
- logs and stack traces
- environment variable names (and sometimes secrets, if pasted)
Recommendations:

- don’t commit learned/ to the repo unless you curate and redact
- scan for sensitive content before extracting (see Security guide)
- extract transferable methods, not project-private details
## 5) Turning “learning” into a team habit

A practical cadence:

- after each task: write a 3-line handoff (see Session continuity & strategic compaction)
- weekly: curate 2–3 reusable patterns into formal Skills/Rules/Commands
- large projects: put codemaps + docs sync on a schedule (see Docs sync & codemaps)
## Reference

- Related pages on this site:Session continuity & strategic compaction
- Security guide
