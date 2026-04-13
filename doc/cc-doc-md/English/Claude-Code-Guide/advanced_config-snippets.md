# Claude-Code / Advanced / Config-Snippets

> 来源: claudecn.com

# Config Snippet Library: Portable Templates from Mature Setups

This page extracts the most reusable pieces from mature Claude Code configurations into copyable snippets, so you can quickly roll them out to:

- ~/.claude/ (personal/global)
- .claude/ (project/team-shared)
All snippets are sourced from public configurations (see “References”). You still need to tailor them to your team constraints and environment.

## 1) Minimal directory skeleton (start here)

Split “bottom lines + workflows + roles + automation” into reviewable files:

```text
your-repo/
├─ CLAUDE.md
└─ .claude/
   ├─ rules/
   ├─ commands/
   ├─ agents/
   ├─ hooks/
   └─ settings.json
```

For more complete rollout paths:

- Config as code
- Team Starter Kit
## 2) Project-level CLAUDE.md: write “facts and bottom lines” as the entrypoint

Typical structure (excerpt):

```markdown
## Critical Rules

### 1. Code Organization

- Many small files over few large files
- High cohesion, low coupling
- 200-400 lines typical, 800 max per file

### 3. Testing

- TDD: Write tests first
- 80% minimum coverage

### 4. Security

- No hardcoded secrets
- Validate all user inputs
```

You can rewrite it in your team’s language, but keep it **executable** (real test/build commands, clear “no-go” zones).

## 3) User-level ~/.claude/CLAUDE.md: global principles + modular rule entrypoints

User scope is better for cross-project philosophy (excerpt):

```markdown
## Core Philosophy

**Key Principles:**
1. **Agent-First**: Delegate to specialized agents for complex work
2. **Parallel Execution**: Use Task tool with multiple agents when possible
3. **Plan Before Execute**: Use Plan Mode for structured approach
4. **Test-Driven**: Write tests before implementation
5. **Security-First**: Never compromise on security
```

To separate “global preferences” from “project constraints”, pair this with [Context management](https://claudecn.com/en/docs/claude-code/workflows/context-management/).

## 4) /commands: turn repeated workflows into enforced entrypoints

Instead of repeatedly reminding “plan first, then edit”, codify workflows in command templates (excerpt):

```markdown
---
description: Restate requirements, assess risks, and create step-by-step implementation plan. WAIT for user CONFIRM before touching any code.
---
```

Related rollout guidance:

- Custom commands
- Quality gates
## 5) hooks/hooks.json: automate guardrails (remind / validate / block)

These hook snippets are directly portable.

Different repos structure Hooks differently: some use a dedicated `hooks/hooks.json`, others embed hooks under `.claude/settings.json`. The **hook logic is equivalent**—only the “wrapper” changes.

### 5.1 Long-command reminder: suggest tmux (reminder)

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm (install|test)|pnpm (install|test)|yarn (install|test)|bun (install|test)|cargo build|make|docker|pytest|vitest|playwright)\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\ninput=$(cat)\nif [ -z \"$TMUX\" ]; then\n  echo '[Hook] Consider running in tmux for session persistence' >&2\n  echo '[Hook] tmux new -s dev  |  tmux attach -t dev' >&2\nfi\necho \"$input\""
    }
  ],
  "description": "Reminder to use tmux for long-running commands"
}
```

### 5.2 Pause before git push (interactive)

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"git push\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Open editor for review before pushing\necho '[Hook] Review changes before push...' >&2\n# Uncomment your preferred editor:\n# zed . 2>/dev/null\n# code . 2>/dev/null\n# cursor . 2>/dev/null\necho '[Hook] Press Enter to continue with push or Ctrl+C to abort...' >&2\nread -r"
    }
  ],
  "description": "Pause before git push to review changes"
}
```

### 5.3 console.log audit: warn after edit + scan on Stop
Warn after edits:

```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx|js|jsx)$\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Warn about console.log in edited files\ninput=$(cat)\nfile_path=$(echo \"$input\" | jq -r '.tool_input.file_path // \"\"')\n\nif [ -n \"$file_path\" ] && [ -f \"$file_path\" ]; then\n  console_logs=$(grep -n \"console\\\\.log\" \"$file_path\" 2>/dev/null || true)\n  \n  if [ -n \"$console_logs\" ]; then\n    echo \"[Hook] WARNING: console.log found in $file_path\" >&2\n    echo \"$console_logs\" | head -5 >&2\n    echo \"[Hook] Remove console.log before committing\" >&2\n  fi\nfi\n\necho \"$input\""
    }
  ],
  "description": "Warn about console.log statements after edits"
}
```

Scan on Stop:

```json
{
  "matcher": "*",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Final check for console.logs in modified files\ninput=$(cat)\n\nif git rev-parse --git-dir > /dev/null 2>&1; then\n  modified_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\\\\.(ts|tsx|js|jsx)

### 5.4 Block edits on main (blocker)
Example:

```json
{
  "matcher": "Edit|MultiEdit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "[ \"$(git branch --show-current)\" != \"main\" ] || { echo '{\"block\": true, \"message\": \"Cannot edit files on main branch. Create a feature branch first.\"}' >&2; exit 2; }",
      "timeout": 5
    }
  ]
}
```

### 5.5 Run related tests after editing test files (automation; caution)
Excerpt:

```json
{
  "matcher": "Edit|MultiEdit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" =~ \\\\.test\\\\.(js|jsx|ts|tsx)$ ]]; then\\n  npm test -- --findRelatedTests \"${CLAUDE_TOOL_INPUT_FILE_PATH}\" --passWithNoTests 2>&1 | tail -30\\nfi",
      "timeout": 90
    }
  ]
}
```

Rollout tip: pilot in one repo first; if tests are slow/flaky, convert to reminders or run only in CI.

### 5.6 Auto-install deps after package.json changes (automation; caution)

Excerpt:

```json
{
  "matcher": "Edit|MultiEdit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" =~ package\\\\.json$ ]]; then\\n  npm install >/dev/null 2>&1\\nfi",
      "timeout": 60
    }
  ]
}
```

Rollout tip: replace with your package manager; consider triggering only on lockfile changes.

### 5.7 UserPromptSubmit: suggest which Skills to use (reminder)

Excerpt:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/skill-eval.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

For more hook recipes: see [Hooks recipes](https://claudecn.com/en/docs/claude-code/advanced/hooks-recipes/).

## 6) mcp-servers.json: start with placeholders and a small set

Excerpt:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT_HERE"
      },
      "description": "GitHub operations - PRs, issues, repos"
    }
  }
}
```

See [MCP servers](https://claudecn.com/en/docs/claude-code/advanced/mcp-servers/) for scope details.

Another shared `.mcp.json` template (example):

```json
{
  "mcpServers": {
    "jira": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-jira"],
      "env": {
        "JIRA_HOST": "${JIRA_HOST}",
        "JIRA_EMAIL": "${JIRA_EMAIL}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    },
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## References

- Related pages on this site:Config as Code
- Hooks
- MCP servers
 || true)\n  \n  if [ -n \"$modified_files\" ]; then\n    has_console=false\n    while IFS= read -r file; do\n      if [ -f \"$file\" ]; then\n        if grep -q \"console\\\\.log\" \"$file\" 2>/dev/null; then\n          echo \"[Hook] WARNING: console.log found in $file\" >&2\n          has_console=true\n        fi\n      fi\n    done <<< \"$modified_files\"\n    \n    if [ \"$has_console\" = true ]; then\n      echo \"[Hook] Remove console.log statements before committing\" >&2\n    fi\n  fi\nfi\n\necho \"$input\""
    }
  ],
  "description": "Final audit for console.log in modified files before session ends"
}
```

### 5.4 Block edits on main (blocker)
Example:

%%CODE_BLOCK_8%%

### 5.5 Run related tests after editing test files (automation; caution)
Excerpt:

%%CODE_BLOCK_9%%

Rollout tip: pilot in one repo first; if tests are slow/flaky, convert to reminders or run only in CI.

### 5.6 Auto-install deps after package.json changes (automation; caution)

Excerpt:

%%CODE_BLOCK_10%%

Rollout tip: replace with your package manager; consider triggering only on lockfile changes.

### 5.7 UserPromptSubmit: suggest which Skills to use (reminder)

Excerpt:

%%CODE_BLOCK_11%%

For more hook recipes: see [Hooks recipes](https://claudecn.com/en/docs/claude-code/advanced/hooks-recipes/).

## 6) mcp-servers.json: start with placeholders and a small set

Excerpt:

%%CODE_BLOCK_12%%

See [MCP servers](https://claudecn.com/en/docs/claude-code/advanced/mcp-servers/) for scope details.

Another shared `.mcp.json` template (example):

%%CODE_BLOCK_13%%

## References

- Related pages on this site:Config as Code
- Hooks
- MCP servers
