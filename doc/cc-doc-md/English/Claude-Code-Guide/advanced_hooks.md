# Claude-Code / Advanced / Hooks

> 来源: claudecn.com

# Hooks System

Hooks enable you to execute custom [ scripts](#) at specific points in Claude Code’s workflow—automating tasks like formatting, validation, notifications, and more.

## Event Types

| Event | Trigger |
| --- | --- |
| `PreToolUse` | Before tool execution |
| `PostToolUse` | After tool completion |
| `Stop` | When Claude finishes response |
| `SubagentStop` | When subagent completes |
| `Notification` | On desktop notification |
| `UserPromptSubmit` | Before processing user input |
| `PermissionRequest` | When permission prompt appears |
| `PreCompact` | Before context compaction |
| `SessionStart` | When session begins |
| `SessionEnd` | When session ends |

---

## Configuration

Hooks can be defined in:

- ~/.claude/settings.json (user)
- .claude/settings.json (project)
- Subagent YAML frontmatter
- Plugin manifests
### Basic Structure

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix \"$TOOL_INPUT_file_path\""
          }
        ]
      }
    ]
  }
}
```

---

## Hook Types

### Command-based Hooks
Execute shell commands:

```json
{
  "type": "command",
  "command": "prettier --write \"$TOOL_INPUT_file_path\""
}
```

### Prompt-based Hooks
Invoke LLM for decisions:

```json
{
  "type": "prompt",
  "prompt": "Are you confident this response fully addresses the user's question?"
}
```

---

## Exit Codes

| Code | Behavior |
| --- | --- |
| `0` | Success, continue |
| `2` | Block tool/stop operation |
| Other | Error logged, continue |

---

## Environment Variables
Available in hook commands:

| Variable | Description |
| --- | --- |
| `CLAUDE_PROJECT_DIR` | Project directory |
| `TOOL_NAME` | Current tool name |
| `TOOL_INPUT_*` | Tool input parameters |
| `TOOL_OUTPUT` | Tool output (PostToolUse) |

---

## Practical Examples

### Auto-format on Edit

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "prettier --write \"$TOOL_INPUT_file_path\" 2>/dev/null || true"
      }]
    }]
  }
}
```

### Block Dangerous Commands

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "if echo \"$TOOL_INPUT_command\" | grep -qE 'rm -rf|sudo|chmod 777'; then exit 2; fi"
      }]
    }]
  }
}
```

### Session Initialization

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "source ~/.nvm/nvm.sh && nvm use"
      }]
    }]
  }
}
```

### Smart Stop Check

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "prompt": "Did you fully complete the task? If not, continue."
      }]
    }]
  }
}
```

---

## Security Best Practices

- Validate inputs: Don’t trust $TOOL_INPUT_* blindly
- Use absolute paths: Avoid path injection
- Limit scope: Apply hooks only where needed
- Handle errors: Always handle command failures gracefully
---

## Debugging

```bash
# View hook execution logs
claude --debug

# Test hook command manually
TOOL_INPUT_file_path="test.js" bash -c 'your-hook-command'
```

---

## Next Steps
[Agent SkillsCreate reusable knowledge modules
](../skills/)[SubagentsCreate specialized sub-agents
](../subagents/)
