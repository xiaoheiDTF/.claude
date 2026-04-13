# Claude-Code / Advanced / Hooks-Recipes

> 来源: claudecn.com

# Hooks Recipes: Turn Lessons into Automated Guardrails

Hooks are how you convert recurring mistakes (forgot tests, lost dev server logs, accidental pushes, leftover `console.log`, doc fragmentation) into automation guardrails. This page highlights generally useful recipes and explains when to use (or avoid) them.

Hooks directly affect your workflow. Start with “reminder” hooks, then gradually adopt “blocking” hooks.

Hook scripts often rely on environment variables injected by Claude Code:

- $CLAUDE_TOOL_INPUT_FILE_PATH: file path involved in this operation
- $CLAUDE_TOOL_NAME: tool name that triggered the hook
- $CLAUDE_PROJECT_DIR: project root
Blocking in `PreToolUse` commonly uses exit codes (e.g. `exit 2` blocks the tool call).

## 1) Long-command reminder: suggest tmux (reminder)

Use case: long-running tasks (install/test/build/docker/pytest) where losing logs/context is painful.

Example:

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm (install|test)|pnpm (install|test)|yarn (install|test)|bun (install|test)|cargo build|make|docker|pytest|vitest|playwright)\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\ninput=$(cat)\nif [ -z \"$TMUX\" ]; then\n  echo '[Hook] Consider running in tmux for session persistence' >&2\n  echo '[Hook] tmux new -s dev  |  tmux attach -t dev' >&2\nfi\necho \"$input\""
    }
  ]
}
```

## 2) Force dev server to run in tmux (blocker)
Use case: make dev server logs traceable and persistent.

Example (verbatim excerpt):

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm run dev|pnpm( run)? dev|yarn dev|bun run dev)\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\ninput=$(cat)\ncmd=$(echo \"$input\" | jq -r '.tool_input.command // \"\"')\n\n# Block dev servers that aren't run in tmux\necho '[Hook] BLOCKED: Dev server must run in tmux for log access' >&2\necho '[Hook] Use this command instead:' >&2\necho \"[Hook] tmux new-session -d -s dev 'npm run dev'\" >&2\necho '[Hook] Then: tmux attach -t dev' >&2\nexit 1"
    }
  ],
  "description": "Block dev servers outside tmux - ensures you can access logs"
}
```

Rollout tip: if your team doesn’t use tmux, start with a reminder hook instead.

## 3) Pause before git push (reminder/interactive)

Use case: force a quick review before pushing.

Example (verbatim excerpt):

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

## 4) Auto-format and typecheck after edits (consistency automation)
Use case: reduce review overhead by baking in formatting/type safety.

### 4.1 Auto-format JS/TS via Prettier

```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx|js|jsx)$\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Auto-format with Prettier after editing JS/TS files\ninput=$(cat)\nfile_path=$(echo \"$input\" | jq -r '.tool_input.file_path // \"\"')\n\nif [ -n \"$file_path\" ] && [ -f \"$file_path\" ]; then\n  if command -v prettier >/dev/null 2>&1; then\n    prettier --write \"$file_path\" 2>&1 | head -5 >&2\n  fi\nfi\n\necho \"$input\""
    }
  ],
  "description": "Auto-format JS/TS files with Prettier after edits"
}
```

### 4.2 Incremental TS check via tsc

```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"\\\\.(ts|tsx)$\"",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Run TypeScript check after editing TS files\ninput=$(cat)\nfile_path=$(echo \"$input\" | jq -r '.tool_input.file_path // \"\"')\n\nif [ -n \"$file_path\" ] && [ -f \"$file_path\" ]; then\n  dir=$(dirname \"$file_path\")\n  project_root=\"$dir\"\n  while [ \"$project_root\" != \"/\" ] && [ ! -f \"$project_root/package.json\" ]; do\n    project_root=$(dirname \"$project_root\")\n  done\n  \n  if [ -f \"$project_root/tsconfig.json\" ]; then\n    cd \"$project_root\" && npx tsc --noEmit --pretty false 2>&1 | grep \"$file_path\" | head -10 >&2 || true\n  fi\nfi\n\necho \"$input\""
    }
  ]
}
```

## 5) console.log guardrails: warn on edit + scan on Stop
Warn after edit:

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

Rollout tip: if logs are allowed, adjust the matcher (e.g., check `logger.debug`) or scope to `src/`.

## 6) Prevent “random doc fragmentation” (blocker; caution)

Use case: keep docs consolidated; avoid creating many random `.md/.txt` files in app repos.

Example (excerpt):

```json
{
  "matcher": "tool == \"Write\" && tool_input.file_path matches \"\\\\.(md|txt)$\" && !(tool_input.file_path matches \"README\\\\.md|CLAUDE\\\\.md|AGENTS\\\\.md|CONTRIBUTING\\\\.md\")",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\n# Block creation of unnecessary documentation files\ninput=$(cat)\nfile_path=$(echo \"$input\" | jq -r '.tool_input.file_path // \"\"')\n\nif [[ \"$file_path\" =~ \\.(md|txt)$ ]] && [[ ! \"$file_path\" =~ (README|CLAUDE|AGENTS|CONTRIBUTING)\\.md$ ]]; then\n  echo \"[Hook] BLOCKED: Unnecessary documentation file creation\" >&2\n  echo \"[Hook] File: $file_path\" >&2\n  echo \"[Hook] Use README.md for documentation instead\" >&2\n  exit 1\nfi\n\necho \"$input\""
    }
  ],
  "description": "Block creation of random .md files - keeps docs consolidated"
}
```

Boundary: this is not suitable for documentation-driven repos (like Hugo sites). It fits application codebases.

## 7) Pair Hooks with continuity and continuous learning

Two high-ROI patterns:

- SessionStart/SessionEnd: write handoff files (see Session continuity)
- Stop: prompt a lightweight retrospective (see Continuous learning)
## 8) Extra recipes (advanced)

These are “engineering-system style” guardrails you can pilot before rolling out broadly.

### 8.1 Block editing on main (PreToolUse blocker)

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

### 8.2 Run related tests after editing test files (PostToolUse automation)

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

### 8.3 Auto-install deps after package.json changes (PostToolUse automation)

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

Automation recipes add latency and environment dependencies (`npm install`, test runs). If your toolchain isn’t Node (or uses different package managers), start as reminders or enable only in CI.

## Reference

- Claude Code Hooks (official): https://code.claude.com/docs/en/hooks
 || true)\n  \n  if [ -n \"$modified_files\" ]; then\n    has_console=false\n    while IFS= read -r file; do\n      if [ -f \"$file\" ]; then\n        if grep -q \"console\\\\.log\" \"$file\" 2>/dev/null; then\n          echo \"[Hook] WARNING: console.log found in $file\" >&2\n          has_console=true\n        fi\n      fi\n    done <<< \"$modified_files\"\n    \n    if [ \"$has_console\" = true ]; then\n      echo \"[Hook] Remove console.log statements before committing\" >&2\n    fi\n  fi\nfi\n\necho \"$input\""
    }
  ],
  "description": "Final audit for console.log in modified files before session ends"
}
```

Rollout tip: if logs are allowed, adjust the matcher (e.g., check `logger.debug`) or scope to `src/`.

## 6) Prevent “random doc fragmentation” (blocker; caution)

Use case: keep docs consolidated; avoid creating many random `.md/.txt` files in app repos.

Example (excerpt):

%%CODE_BLOCK_7%%

Boundary: this is not suitable for documentation-driven repos (like Hugo sites). It fits application codebases.

## 7) Pair Hooks with continuity and continuous learning

Two high-ROI patterns:

- SessionStart/SessionEnd: write handoff files (see Session continuity)
- Stop: prompt a lightweight retrospective (see Continuous learning)
## 8) Extra recipes (advanced)

These are “engineering-system style” guardrails you can pilot before rolling out broadly.

### 8.1 Block editing on main (PreToolUse blocker)

%%CODE_BLOCK_8%%

### 8.2 Run related tests after editing test files (PostToolUse automation)

%%CODE_BLOCK_9%%

### 8.3 Auto-install deps after package.json changes (PostToolUse automation)

%%CODE_BLOCK_10%%

Automation recipes add latency and environment dependencies (`npm install`, test runs). If your toolchain isn’t Node (or uses different package managers), start as reminders or enable only in CI.

## Reference

- Claude Code Hooks (official): https://code.claude.com/docs/en/hooks
