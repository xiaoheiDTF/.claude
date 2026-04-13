# Claude-Code / Advanced / Skills

> 来源: claudecn.com

# Agent Skills

Skills are reusable sets of instructions that guide Claude’s behavior. They extend Claude’s capabilities with specialized knowledge for specific tasks.

## Further Reading

- Start from first principles: /en/docs/claude-code/advanced/agent-loop/
- Skills as knowledge packs: /en/docs/claude-code/advanced/agent-loop/v4-skills/
## How Skills Work

- Discovery: Claude finds Skills in .claude/skills/, ~/.claude/skills/, or plugins
- Activation: Claude decides whether a Skill applies to the current task
- Execution: Claude follows the Skill’s instructions to complete the task
---

## Creating Your First Skill

### Step 1: Create the Skill File

```bash
mkdir -p .claude/skills
touch .claude/skills/SKILL.md
```

### Step 2: Write the Skill

```markdown
---
name: commit-message
description: Generate clear, consistent commit messages. Used when creating commits or writing commit messages.
---

When writing commit messages, follow this format:

**Title**: `<type>(<scope>): <subject>`

Types: feat, fix, docs, style, refactor, test, chore

**Body**: Explain what and why, not how

**Footer**: Reference issues with `Closes #123`
```

### Step 3: Test the Skill

```
> Generate a commit message for my current changes
```

Claude will automatically apply your commit message guidelines.

---

## Skill Metadata Fields

| Field | Required | Description |
| --- | --- | --- |
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When to use this Skill |
| `allowed-tools` | No | Restrict available tools |
| `context` | No | `fork` for isolated context |
| `hooks` | No | Event-triggered scripts |
| `user-invocable` | No | Allow manual invocation |

---

## Storage Locations

| Location | Scope | Use Case |
| --- | --- | --- |
| `.claude/skills/` | Project | Team-shared Skills |
| `~/.claude/skills/` | User | Personal Skills |
| Plugin bundle | Plugin | Distributed Skills |

---

## Advanced: Multi-File Skills

For complex Skills, use progressive disclosure:

```
.claude/skills/
└── api-design/
    ├── SKILL.md           # Main instructions
    ├── reference.md       # Detailed reference
    └── examples.md        # Examples
```

In `SKILL.md`:

```markdown
For REST conventions, refer to `reference.md`
For practical examples, see `examples.md`
```

---

## Restricting Tools
Limit which tools a Skill can use:

```yaml
---
name: read-only-analysis
description: Analyze code without modifications
allowed-tools:
  - Read
  - Glob
  - Grep
---
```

---

## Skills vs Other Features

| Feature | Purpose | When |
| --- | --- | --- |
| **Skills** | Reusable prompts | Auto-applied contextually |
| **Subagents** | Isolated specialized agents | Multi-step complex tasks |
| **MCP** | External tool integration | APIs, databases, browsers |

---

## Troubleshooting
**Skill not triggering?**

- Check description matches your use case
- Verify file location (.claude/skills/)
- Test with explicit mention
**Skill not loading?**

- Validate YAML frontmatter syntax
- Check file permissions
- Use /skills to list loaded Skills
