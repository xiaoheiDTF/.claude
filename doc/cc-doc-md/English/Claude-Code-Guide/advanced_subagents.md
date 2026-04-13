# Claude-Code / Advanced / Subagents

> 来源: claudecn.com

# Subagents

Subagents are specialized AI assistants that run in isolated contexts. They’re perfect for delegating specific tasks while keeping your main conversation focused.

## Built-in Subagents

### Explore Subagent

Read-only exploration with tools: Read, Glob, Grep.

```
> @explore find all places where authentication is implemented
```

### Plan Subagent
Strategic planning without code modification.

```
> @plan design a caching layer for the API
```

### General-purpose Subagent
Full tool access for autonomous task execution.

```
> @subagent run linting, testing, and fix any issues found
```

### Other Helper Agents
Claude Code includes additional helper agents for specific tasks:

| Agent | Model | Purpose |
| --- | --- | --- |
| Bash | Inherits | Running terminal commands in separate context |
| statusline-setup | Sonnet | When you run `/statusline` to configure status line |
| Claude Code Guide | Haiku | Answering questions about Claude Code features |

---

## Creating Custom Subagents

### Method 1: Using /agents Command

```
> /agents
```

Follow the interactive prompts to create a new subagent:

- Select scope: User-level (available across all projects) or Project-level
- Generate with Claude: Describe what you want the subagent to do
- Select tools: Choose available tools (Read-only, All, or custom selection)
- Select model: Sonnet (balanced), Opus (most capable), Haiku (fastest), or inherit
- Choose color: Pick a background color to identify the subagent in UI
### Method 2: Manual Creation

Create `.claude/agents/code-reviewer.md`:

```markdown
---
name: code-reviewer
description: Professional code reviewer for quality and security
tools:
  - Read
  - Glob
  - Grep
  - Bash
model: inherit
---

You are a senior code reviewer.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review Checklist:
- Code clarity and readability
- Proper error handling
- No exposed secrets
- Input validation
- Test coverage

Organize feedback by priority:
- Critical Issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)
```

---

## Configuration Options

| Field | Description | Example |
| --- | --- | --- |
| `name` | Unique identifier | `code-reviewer` |
| `description` | When to use | `Review code quality` |
| `tools` | Allowed tools | `[Read, Glob, Bash]` |
| `model` | Model to use | `inherit` or specific model |
| `permissionMode` | Permission handling | `default`, `acceptEdits`, `bypassPermissions` |
| `skills` | Skills to include | `[commit-message]` |
| `hooks` | Event hooks | PreToolUse, PostToolUse |

---

## Execution Modes

### Foreground (Default)

- Output streams to main conversation
- Stops for permission requests
- Use for interactive tasks
### Background

- Runs autonomously
- Results returned when complete
- Use for long-running independent tasks
---

## Practical Patterns

### Isolating Output
Keep noisy operations separate:

```
> @subagent analyze the entire node_modules structure
```

### Parallel Research
Run multiple explorations simultaneously:

```
> @explore research frontend auth patterns
> @explore research backend session management
```

### Resuming Subagents
Resume a terminated subagent:

```
claude --resume
```

---

## Classic Examples

### Debugger

```yaml
---
name: debugger
description: Expert debugger for systematic issue resolution
tools: [Read, Glob, Grep, Bash]
---

Debugging approach:
1. Reproduce the issue
2. Gather evidence (logs, traces)
3. Form hypotheses
4. Test systematically
5. Document root cause
```

### Database Reader

```yaml
---
name: db-reader
description: Safe database query agent
tools: [Read, Bash]
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: |
            if echo "$TOOL_INPUT" | grep -qiE "(INSERT|UPDATE|DELETE|DROP|ALTER)"; then
              echo "Blocked: Only SELECT queries allowed"
              exit 2
            fi
---

Query database safely. Only SELECT queries permitted.
```

---

## Further Reading

- Start from the core loop: /en/docs/claude-code/advanced/agent-loop/
- Context isolation with subagents: /en/docs/claude-code/advanced/agent-loop/v3-subagents/
## When to Use Subagents

| Scenario | Use |
| --- | --- |
| Multiple parallel tasks | Subagents |
| Need isolated context | Subagent |
| Quick one-off question | Main conversation |
| Continuous dialogue | Main conversation |
