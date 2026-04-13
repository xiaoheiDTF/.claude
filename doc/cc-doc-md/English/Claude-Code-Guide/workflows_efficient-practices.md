# Claude-Code / Workflows / Efficient-Practices

> 来源: claudecn.com

# Efficient Practices

Tips for working efficiently with Claude Code.

## Start with Plan Mode

For complex tasks, explore first before making changes:

```bash
claude --permission-mode plan
```

Or press **Shift+Tab** to toggle to Plan Mode.

## Use Subagents for Research

Delegate exploration to subagents:

```
> @explore Find all authentication-related code
> @plan Design a caching strategy
```

## Batch Processing
Handle multiple items together:

```
> Add error handling to all API endpoints
> Update imports across all files
```

## Use CLAUDE.md Effectively
Document patterns and conventions:

```markdown
# Project Guidelines

## Testing
- Run `npm test` for all tests
- Use `npm test -- --watch` during development

## Code Style
- Use TypeScript strict mode
- Prefer async/await over callbacks
```

## Keyboard Shortcuts

| Shortcut | Action |
| --- | --- |
| `Tab` | Autocomplete file paths |
| `↑` | Previous command |
| `Escape` | Interrupt operation |
| `Shift+Tab` | Toggle permission mode |
| `Ctrl+B` | Send to background |

## Session Management

```bash
# Continue recent conversation
claude -c

# Resume specific session
claude --resume

# Start fresh
claude
```

## Optimize Prompts

- Be specific about files and locations
- Provide examples when possible
- Break complex tasks into steps
- Ask Claude to explain before implementing
## Use /clear Wisely
Clear context when:

- Switching to a different task
- Context becomes polluted
- Starting fresh analysis
## Background Tasks

For long-running operations:

```
> Run this in the background
```

Or press **Ctrl+B** to send current task to background.
