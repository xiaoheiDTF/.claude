# Claude-Code / Reference / Statusline

> 来源: claudecn.com

# Statusline

Statusline shows live Claude Code session info at the bottom of your terminal (model, working dir, context usage, etc.). Run `/statusline` in Claude Code and follow the prompts.

## Statusline input (stdin JSON)

Your statusline command receives JSON on stdin (fields may evolve by version), such as:

- model.display_name: current model display name
- workspace.current_dir: current working directory
- context_window.used_percentage / context_window.remaining_percentage: context window usage/remaining percentage (0–100)
- context_window.current_usage: token usage of the last request (may be null)
## Minimal example: show model + context usage

```bash
#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
model="$(echo "$input" | jq -r '.model.display_name // "unknown"')"
used="$(echo "$input" | jq -r '.context_window.used_percentage // 0')"

echo "[$model] Context: ${used}%"
```

Prefer `used_percentage` / `remaining_percentage`: they’re precomputed and more stable. Only derive from `current_usage` if you need a custom formula.

## Next steps
[Quick referenceCommon commands and shortcuts
](../quick-reference)[Advent of ClaudeHigh-frequency tips
](../../workflows/advent-of-claude)
