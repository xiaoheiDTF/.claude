# Claude-Code / Workflows / Code-Changes

> 来源: claudecn.com

# Code Changes

Best practices for making code changes with Claude Code.

## Review Before Approve

Claude always shows proposed changes before execution. Review carefully:

```
> Add input validation to the form
[Claude shows proposed changes]
[Review the diff]
[Accept or reject]
```

## Accept Modes
Press **Shift+Tab** to cycle through modes:

- Normal Mode: Confirm each operation
- Accept Edits Mode: Auto-accept file edits
- Plan Mode: Read-only exploration
## Safe Editing Workflow

- Explore first: Understand the code before changing
- Small changes: Make incremental modifications
- Test after: Run tests to verify changes
- Commit often: Save progress with version control
## Common Edit Operations

### Adding Code

```
> Add a new function to handle user logout
```

### Modifying Code

```
> Update the API endpoint to use the new format
```

### Removing Code

```
> Remove the deprecated login method
```

### Refactoring

```
> Refactor to use async/await instead of callbacks
```

## Multi-File Changes
Claude can coordinate changes across files:

```
> Rename the User model to Account and update all references
```

## Handling Errors
If something goes wrong:

```
> Undo the last change
> That didn't work, try a different approach
> Revert to the previous version
```

## Best Practices

- Commit before major changes - Easy to revert
- Review every diff - Catch issues early
- Test after changes - Verify behavior
- Use git diff - Review all changes before committing
