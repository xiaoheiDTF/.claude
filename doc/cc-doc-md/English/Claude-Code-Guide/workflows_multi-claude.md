# Claude-Code / Workflows / Multi-Claude

> 来源: claudecn.com

# Multi-Claude

Techniques for using multiple Claude Code instances and sessions.

## Multiple Terminals

Run Claude Code in separate terminals for different tasks:

**Terminal 1: Frontend development**

```bash
cd frontend && claude
```

**Terminal 2: Backend development**

```bash
cd backend && claude
```

## Background Subagents
Run research tasks in the background:

```
> Run this analysis in the background
```

Press **Ctrl+B** to send a running task to background.

## Parallel Research

Use subagents for parallel exploration:

```
> @explore Research the authentication module
> @explore Research the database layer
```

## Shared Context via CLAUDE.md
When working in the same codebase:

- Use /init to create shared project context
- Commit CLAUDE.md to version control
- All Claude instances benefit from the same context
## Session Management

**Resume a session:**

```bash
claude --resume
```

**Continue in current directory:**

```bash
claude -c
```

**List recent sessions:**

```bash
claude --list-sessions
```

## Use Cases

### Code Review + Development

- Terminal 1: Implement feature
- Terminal 2: Review changes as you go
### Frontend + Backend

- Terminal 1: Work on API endpoints
- Terminal 2: Build UI components
### Research + Implementation

- Background: Deep dive into patterns
- Foreground: Implement based on findings
## Best Practices

- Use separate directories - Avoid file conflicts
- Coordinate on Git - Pull before pushing
- Share via CLAUDE.md - Consistent project context
- Use subagents for research - Keep main session focused
