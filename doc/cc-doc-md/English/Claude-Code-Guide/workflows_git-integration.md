# Claude-Code / Workflows / Git-Integration

> 来源: claudecn.com

# Git Integration

Claude Code integrates seamlessly with Git for version control.

## Common Git Operations

### Check Status

```
> What files have I changed?
> Show uncommitted changes
> What's the current branch?
```

### View Changes

```
> Show the diff for the last commit
> What changed in auth.ts?
```

### Commit

```
> Commit my changes with a descriptive message
> Commit only the changes to src/
```

### Branch Management

```
> Create a new branch for this feature
> Switch to the main branch
> List all branches
```

### Merge and Rebase

```
> Merge the feature branch into main
> Rebase my branch on main
> Help me resolve merge conflicts
```

## Using claude commit
Quick commit command:

```bash
claude commit
```

Claude will:

- Analyze your changes
- Generate a descriptive commit message
- Ask for approval
- Create the commit
## Pull Request Workflow

```
> Create a pull request for my changes
> Summarize changes for a PR description
> Review the changes before PR
```

## Conflict Resolution

```
> Help me resolve the merge conflicts
> Show me the conflicting files
> Explain what each side of the conflict does
```

## Undo Operations

```
> Undo the last commit
> Discard changes to this file
> Reset to the previous state
```

## Best Practices

- Commit frequently - Small, focused commits
- Write descriptive messages - Explain what and why
- Review before committing - Use git diff
- Use branches - Isolate feature work
- Keep main clean - Merge only tested code
