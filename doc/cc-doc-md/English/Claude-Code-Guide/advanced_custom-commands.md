# Claude-Code / Advanced / Custom-Commands

> 来源: claudecn.com

# Custom Commands

Custom commands let you store commonly used prompt templates as reusable commands, invoked with simple slash commands.

## Command File Locations

Claude Code supports two levels of custom commands:

| Level | Location | Invocation |
| --- | --- | --- |
| Project | `.claude/commands/` | `/project:` |
| Global | `~/.claude/commands/` | `/` |

## Command Syntax

Command files are plain Markdown using `$ARGUMENTS` placeholder for user input.

### Basic Structure

```markdown
Please analyze the following issue and provide a solution:

$ARGUMENTS

Requirements:
1. Analyze root cause
2. Provide fix recommendations
3. Consider edge cases
```

## Examples

### fix-github-issue.md

```markdown
Please fix the following GitHub Issue:

$ARGUMENTS

Steps:
1. Analyze the issue description and related code
2. Identify root cause
3. Implement the fix
4. Add necessary tests
5. Ensure existing tests pass
```

### debug.md

```markdown
Debug the following issue:

$ARGUMENTS

Debug process:
1. Reproduce the issue
2. Check relevant logs and error messages
3. Locate problem code
4. Analyze possible causes
5. Propose fix
```

### review.md

```markdown
Perform a code review on:

$ARGUMENTS

Review focus:
- Code logic correctness
- Error handling completeness
- Performance issues
- Security vulnerabilities
- Code readability and maintainability
```

## Team Sharing
Commit `.claude/commands/` to Git for team sharing:

```bash
git add .claude/commands/
git commit -m "Add Claude Code custom commands"
```

## Best Practices

- Stay focused - Each command does one thing
- Clear instructions - Provide explicit steps and requirements
- Use arguments - Keep commands flexible with $ARGUMENTS
- Good naming - Use descriptive file names
- Document - Add comments explaining purpose
## Usage

```bash
# Project-level command
/project:fix-github-issue #123

# Global command
/debug App shows ECONNREFUSED on startup
```
