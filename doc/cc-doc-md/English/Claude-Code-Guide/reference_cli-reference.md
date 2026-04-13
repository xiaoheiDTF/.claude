# Claude-Code / Reference / Cli-Reference

> 来源: claudecn.com

# CLI Reference

A practical reference for Claude Code CLI usage: common commands, key flags, and system-prompt-related advanced switches. For the canonical list, run `claude --help` on your machine.

## Common commands

| Command | Description | Example |
| --- | --- | --- |
| `claude` | Start an interactive session (REPL) | `claude` |
| `claude "query"` | Start a session with an initial prompt | `claude "Explain this repo structure"` |
| `claude -p "query"` | Print/Headless mode: write to stdout then exit | `claude -p "Explain this function"` |
| `cat file | claude -p "query"` | Process piped input | `cat logs.txt | claude -p "Explain this error"` |
| `claude -c` | Continue the most recent session in current dir | `claude -c` |
| `claude -r "" "query"` | Resume by session name/ID | `claude -r "auth-refactor" "Continue this PR"` |
| `claude update` | Update to the latest version | `claude update` |
| `claude mcp` | Configure MCP servers | `claude mcp` |

## Common flags (selected)

| Flag | Meaning |
| --- | --- |
| `--print`, `-p` | Print/Headless mode (scripting/CI) |
| `--output-format` | Print output format: `text` / `json` / `stream-json` |
| `--input-format` | Print input format: `text` / `stream-json` |
| `--continue`, `-c` | Continue the latest session |
| `--resume`, `-r` | Resume a specific session (or open a picker) |
| `--fork-session` | When resuming, create a new session (don’t overwrite) |
| `--session-id` | Set a session ID (UUID) |
| `--no-session-persistence` | Print mode: don’t write session state to disk |
| `--model` | Choose a model (supports aliases like `sonnet` / `opus`) |
| `--agent` | Choose an agent (override settings `agent`) |
| `--agents` | Define subagents dynamically via JSON |
| `--permission-mode` | Start with a permission mode |
| `--allowedTools` / `--disallowedTools` | Configure tool allow/deny rules |
| `--tools` | Restrict which built-in tools are available |
| `--dangerously-skip-permissions` | Skip all permission prompts (high risk) |
| `--allow-dangerously-skip-permissions` | Allow offering the bypass option (does not enable it) |
| `--append-system-prompt` | Append to the default system prompt |
| `--append-system-prompt-file` | Append system prompt from a file (Print only) |
| `--system-prompt` | Replace the full system prompt (removes defaults) |
| `--system-prompt-file` | Replace system prompt from a file (Print only) |
| `--verbose` | More detailed turn-by-turn logs |
| `--version`, `-v` | Print version |

`--allowedTools` uses the same syntax as `settings.json` permissions. Read the permissions syntax section in the Settings reference—don’t assume `Bash(*)` means “match all Bash”.

## System prompt flags (four variants)
These look similar but mean different things:

| Flag | Behavior | Mode |
| --- | --- | --- |
| `--system-prompt` | **Replace** the default system prompt | Interactive + Print |
| `--system-prompt-file` | **Replace** from a file | Print |
| `--append-system-prompt` | **Append** after the default prompt | Interactive + Print |
| `--append-system-prompt-file` | **Append** from a file | Print |

Prefer the two append variants: they preserve Claude Code default capabilities while layering team rules.

`--system-prompt` and `--system-prompt-file` are mutually exclusive; append flags can be combined with replacement flags.

## --agents (subagents) format

`--agents` accepts a JSON object: keys are agent names; values include `description`, `prompt`, and optional `tools`, `model`, etc.

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Code review with focus on quality/security/best practices",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

## Next steps
[Settings referencesettings.json, permissions, and env vars
](../settings/)[Amazon BedrockThird-party provider setup example
](../amazon-bedrock/)
