# Claude-Code / Getting-Started / Basic-Usage

> 来源: claudecn.com

# Basic Usage

This guide covers essential daily operations with Claude Code.

## Starting and Stopping

```bash
# Start interactive mode
claude

# Run a one-off task
claude "fix the build error"

# Run a query and exit
claude -p "explain this function"

# Continue recent conversation
claude -c
```

## Common Operations

### Reading Code

```
> Explain this file
> What does the authenticate function do?
> Show me how errors are handled
```

### Writing Code

```
> Add input validation to the form
> Create a new API endpoint for users
> Implement the feature described in issue #123
```

### Debugging

```
> Why is this test failing?
> Find the bug causing the login error
> Analyze this error message: [paste error]
```

### Refactoring

```
> Refactor this to use async/await
> Extract common logic into a utility function
> Simplify this complex condition
```

## Working with Files
Claude can:

- Read any file in your project
- Create new files
- Edit existing files
- Delete files (with confirmation)
All modifications require your approval.

## Slash Commands

| Command | Description |
| --- | --- |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/init` | Initialize CLAUDE.md for project |
| `/permissions` | View permission settings |
| `/mcp` | Manage MCP servers |

## Keyboard Shortcuts

| Shortcut | Action |
| --- | --- |
| `Escape` | Interrupt current operation |
| `Ctrl+C` | Exit Claude Code |
| `Tab` | Autocomplete file paths |
| `↑` / `↓` | Navigate command history |
| `Shift+Tab` | Toggle permission mode |

## Best Practices

- Start with exploration: Let Claude understand your codebase first
- Use /clear between tasks: Keep context focused
- Review changes carefully: Always verify before approving
- Use specific descriptions: More detail = better results
