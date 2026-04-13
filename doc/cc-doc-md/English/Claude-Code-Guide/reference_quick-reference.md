# Claude-Code / Reference / Quick-Reference

> 来源: claudecn.com

# Claude Code Quick Reference

For quick lookups: common shortcuts, commands/Skills, and CLI flags in one table. Versions may differ—use your local `claude` `/help` and official docs as the source of truth.

## Keyboard shortcuts

| Shortcut | Purpose |
| --- | --- |
| `!` | Run a Bash command and inject its output into context |
| `Esc` | Interrupt current thinking/execution |
| `Esc Esc` | Rewind to an earlier checkpoint |
| `Ctrl+G` | Edit current input in your default editor (if supported) |
| `Ctrl+R` | Reverse-search prompt history |
| `Ctrl+S` | Stash current prompt draft |
| `Shift+Tab` | Cycle permission modes (includes Plan Mode) |
| `Tab` / `Enter` | Accept prompt suggestions (if supported) |

## Common commands (built-in + Skills)

Tip: type `/` in Claude Code to see the full command list and filter by name. Your own Skills also show up as `/skill-name`.

| Command | Purpose | Read more |
| --- | --- | --- |
| `/help` | Show built-in commands and help | — |
| `/init` | Generate/update `CLAUDE.md` so Claude knows the project | [Context management](https://claudecn.com/en/docs/claude-code/workflows/context-management/) |
| `/clear` | Clear current conversation context | [Context management](https://claudecn.com/en/docs/claude-code/workflows/context-management/) |
| `/compact` | Compact/summarize context (if supported) | [Hooks](https://claudecn.com/en/docs/claude-code/advanced/hooks/) |
| `/config` | View/change config (some settings also in `.claude/settings.json`) | [Settings reference](https://claudecn.com/en/docs/claude-code/reference/settings/) |
| `/permissions` | View/change permissions (if supported) | [Settings reference](https://claudecn.com/en/docs/claude-code/reference/settings/) |
| `/mcp` | Manage MCP connections/auth (if supported) | [MCP servers](https://claudecn.com/en/docs/claude-code/advanced/mcp-servers/) |
| `/model` | Switch model (if supported) | — |
| `/sandbox` | Configure sandbox and permission boundaries | [Security guide](https://claudecn.com/en/docs/claude-code/reference/security/) |
| `/hooks` | Configure Hooks (if supported) | [Hooks](https://claudecn.com/en/docs/claude-code/advanced/hooks/) |
| `/commit` | Generate a commit message and commit | [Git integration](https://claudecn.com/en/docs/claude-code/workflows/git-integration/) |
| `/resume` | Resume a previous session (if supported) | [Basic usage](https://claudecn.com/en/docs/claude-code/getting-started/basic-usage/) |
| `/rename` | Name the current session (if supported) | — |
| `/export` | Export session to Markdown (if supported) | — |
| `/vim` | Vim mode for editing prompts (if supported) | — |
| `/context` | Inspect context/token usage (if supported) | — |
| `/stats` | View usage stats (if supported) | — |
| `/usage` | View quota/limits (if supported) | — |
| `/statusline` | Configure statusline (if supported) | [Statusline](https://claudecn.com/en/docs/claude-code/reference/statusline/) |
| `/tasks` | View/manage background tasks (if supported) | — |
| `/todos` | List TODO items (if supported) | — |
| `/theme` | Switch theme (if supported) | — |

## Common CLI flags

| Flag | Purpose |
| --- | --- |
| `claude ""` | Run a one-off task |
| `claude -c` / `claude --continue` | Continue the last session |
| `claude --resume` | Pick and resume a previous session |
| `claude --permission-mode ` | Start with a permission mode (e.g. `plan`, `acceptEdits`) |
| `claude -p ""` | Headless/Print mode for scripts and CI |
| `claude -p --append-system-prompt-file  ""` | Append system prompt from a file (version team rules) |
| `claude --dangerously-skip-permissions` | Skip permission checks (high risk) |
| `claude --teleport` | Bring a remote claude.ai session local (if supported) |

## Common recipes (copy-paste)

```bash
# Summarize current changes
git diff | claude -p "Summarize these changes and flag potential risks"

# Read-only analysis + plan
claude --permission-mode plan -p "Analyze the auth module and propose a refactor plan"
```

## Related pages

- 31 High-Frequency Tips (Advent of Claude)
- Settings reference
- CLI reference
- Security guide
- Headless mode
