# Claude-Code / Workflows / Plan-Mode

> 来源: claudecn.com

# Plan Mode

Plan Mode enables Claude to analyze your codebase through read-only operations, creating detailed plans before making changes. Perfect for exploring codebases, planning complex changes, or safe code review.

## When to Use Plan Mode

- Multi-step implementations: Features requiring changes across multiple files
- Code exploration: Thorough research before making changes
- Interactive development: Discussing approaches with Claude
---

## Enabling Plan Mode

### Toggle During Session

Press **Shift+Tab** to cycle through permission modes:

```
Normal Mode → Auto-Accept Mode → Plan Mode
```

- Normal Mode: Default, each operation needs confirmation
- Auto-Accept Mode: Auto-accept edits (shows ⏵⏵ accept edits on)
- Plan Mode: Read-only (shows ⏸ plan mode on)
### At Startup

```bash
claude --permission-mode plan
```

### Headless Query

```bash
claude --permission-mode plan -p "Analyze the auth system and suggest improvements"
```

### As Default

```json
// .claude/settings.json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

---

## Typical Workflow

### Planning Complex Refactoring

```bash
claude --permission-mode plan
```

```
> I need to refactor the auth system to use OAuth2. Create a detailed migration plan.
```

Claude analyzes current implementation and creates a comprehensive plan. Refine through follow-up questions:

```
> How do we maintain backward compatibility?
> How should database migration be handled?
```

### Let Claude Interview You
For large features, start with minimal specs and let Claude ask questions:

```
> Interview me about this feature before starting: user notification system
```

```
> Help me think through auth requirements by asking questions
```

Claude uses `AskUserQuestion` tool to gather requirements, clarify ambiguity, and understand preferences.

---

## Combining with Other Features

### Plan Mode + Subagents

In Plan Mode, Claude delegates to the Plan Subagent for read-only research in an isolated context.

### Plan Mode + Extended Thinking

Combine for deeper analysis:

```
> ultrathink: Design a caching layer for the API
```

---

## Best Practices

- Plan before execute: For multi-file changes, analyze first in Plan Mode
- Document decisions: Save generated analysis as design docs
- Iterate: Keep asking until the plan is detailed enough
- Transition: When satisfied, press Shift+Tab to switch to Normal Mode
## Further Reading

- Start from first principles: /en/docs/claude-code/advanced/agent-loop/
- Make plans explicit with Todo: /en/docs/claude-code/advanced/agent-loop/v2-explicit-planning-todo/
