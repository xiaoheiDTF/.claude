# Claude-Code / Advanced / Sdk

> 来源: claudecn.com

# Claude Code SDK

Claude Code SDK enables programmatic integration with Claude Code for automated workflows and custom tools.

## Use Cases

- Automated workflows - Batch code processing
- Tool integration - Integrate with existing toolchains
- CI/CD integration - Use in continuous integration
- Custom interfaces - Build custom interaction interfaces
## Headless Mode

Use `-p` flag for non-interactive mode:

```bash
# Basic usage
claude -p "Explain what this function does"

# Specify working directory
claude -p "Analyze project structure" --cwd /path/to/project
```

## JSON Output
Use `--output-format stream-json` for structured output:

```bash
claude -p "List all TODO comments" --output-format stream-json
```

Output format:

```json
{"type":"text","content":"Found the following TODO comments:"}
{"type":"text","content":"1. src/main.ts:15 - TODO: Add error handling"}
{"type":"result","result":"Scan complete, found 3 TODOs"}
```

## Limit Tools
Use `--allowedTools` to restrict available tools:

```bash
# Only allow read and search
claude -p "Find all test files" --allowedTools Read,Grep,Glob

# No file modifications
claude -p "Code review" --allowedTools Read,Grep
```

## Practical Examples

### Custom Linter

```bash
#!/bin/bash
# custom-lint.sh

claude -p "Check this code for potential issues and output as JSON:
$(cat $1)" --output-format stream-json | \
  jq -r 'select(.type=="result") | .result'
```

### Auto Issue Triage

```bash
#!/bin/bash
# triage-issue.sh

ISSUE_BODY="$1"
RESULT=$(claude -p "Analyze and categorize this issue:
$ISSUE_BODY

Output format:
- Type: bug/feature/question
- Priority: high/medium/low
- Related module: <module-name>" --output-format stream-json)

echo "$RESULT" | jq -r 'select(.type=="result") | .result'
```

### CI Integration
GitHub Actions example:

```yaml
name: Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Claude Code
        run: npm install -g @anthropic/claude-code

      - name: Run Code Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          CHANGED_FILES=$(git diff --name-only origin/main...HEAD)
          
          for file in $CHANGED_FILES; do
            if [[ -f "$file" ]]; then
              echo "Reviewing: $file"
              claude -p "Review this file for issues: $file" \
                --allowedTools Read,Grep \
                --output-format stream-json >> review-results.json
            fi
          done

      - name: Upload Review Results
        uses: actions/upload-artifact@v4
        with:
          name: review-results
          path: review-results.json
```

## Security Best Practices

- API Key ManagementUse environment variables for API keys
- Use Secrets in CI
- Never hardcode in scripts
- Tool RestrictionsLimit tools in production
- Disable unnecessary write permissions
- Input ValidationSanitize user input
- Avoid command injection risks
- Audit LoggingLog all SDK calls
- Monitor for unusual patterns
## Error Handling

```bash
#!/bin/bash

RESULT=$(claude -p "$PROMPT" --output-format stream-json 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "Error: Claude Code failed with exit code $EXIT_CODE"
  echo "$RESULT"
  exit 1
fi

echo "$RESULT" | jq -r 'select(.type=="result") | .result'
```
