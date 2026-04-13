# Claude-Code / Automation / Headless

> 来源: claudecn.com

# Headless Mode

Headless mode runs Claude Code without interaction, suitable for CI/CD pipelines, automation [ scripts](#), and batch processing.

## Basic Usage

Use `-p` to pass prompts; Claude processes and exits:

```bash
# Basic query
claude -p "Explain the architecture of this project"

# JSON output
claude -p "List all TODO comments" --output-format json

# Streaming output
claude -p "Review recent changes" --output-format stream-json
```

---

## Output Formats

### Text (Default)

```bash
claude -p "Summarize README.md"
```

### JSON

```bash
claude -p "Analyze code quality" --output-format json
```

Output:

```json
{
  "type": "result",
  "result": "Analysis result...",
  "cost": 0.0123,
  "duration": 5.2
}
```

### Streaming JSON

```bash
claude -p "Refactor this function" --output-format stream-json
```

---

## Tool Restrictions
Limit available tools in automated environments:

```bash
# Read-only tools only
claude -p "Analyze codebase" --allowedTools "Read,Glob,Grep"

# Disallow specific tools
claude -p "Review code" --disallowedTools "Write,Edit,Bash"
```

### Common Read-Only Tools

| Tool | Description |
| --- | --- |
| `Read` | Read files |
| `Glob` | File pattern matching |
| `Grep` | Content search |
| `Bash(git log:*)` | Allow git log |
| `Bash(git diff:*)` | Allow git diff |

---

## Permission Modes

```bash
# Plan mode (read-only)
claude --permission-mode plan -p "Analyze auth system for potential issues"

# Auto-accept edits (use with caution)
claude --permission-mode acceptEdits -p "Add type annotations"
```

---

## Session Management

### Resume Session

```bash
# Resume most recent
claude --resume -p "Continue previous work"

# Resume specific session
claude --session-id abc123 -p "Complete remaining tasks"
```

### Session Timeout

```bash
# Set max execution time
timeout 600 claude -p "Generate test cases"
```

---

## Environment Variables

| Variable | Description |
| --- | --- |
| `ANTHROPIC_API_KEY` | API key |
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `MAX_TURNS` | Maximum conversation turns |
| `NO_COLOR` | Disable color output |

---

## Pipeline Integration

### Combine with Other Commands

```bash
# Analyze git diff
git diff HEAD~5 | claude -p "Review these changes"

# Process file content
cat error.log | claude -p "Explain these errors"
```

### Script Example

```bash
#!/bin/bash

review_code() {
  local file="$1"
  claude -p "Review $file for quality and security" \
    --allowedTools "Read,Glob,Grep" \
    --output-format json \
    | jq -r '.result'
}

# Batch review
for file in src/*.py; do
  echo "Reviewing: $file"
  review_code "$file" >> review_report.md
done
```

---

## Best Practices

- Limit tool access: Always use --allowedTools for necessary read-only tools
- Set timeouts: Use timeout or --max-turns to prevent infinite runs
- Use JSON output: Easier for programmatic processing
- Isolate environment: Run in containers or sandboxes
- Log everything: Save all Claude operations for auditing
