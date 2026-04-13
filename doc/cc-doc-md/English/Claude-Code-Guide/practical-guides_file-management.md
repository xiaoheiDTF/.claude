# Claude-Code / Practical-Guides / File-Management

> 来源: claudecn.com

# File Management

Guide to managing files with Claude Code.

## Reading Files

```
> Show me the contents of config.json
> Explain what package.json contains
> List all files in src/
```

## Creating Files

```
> Create a new component called UserProfile
> Add a README with installation instructions
> Generate a .gitignore for a Node.js project
```

## Editing Files

```
> Update the API endpoint in config.ts
> Add error handling to the login function
> Remove deprecated code from utils.js
```

## Deleting Files

```
> Delete the unused test files
> Remove legacy.js if it's no longer needed
```

Claude will always ask for confirmation before deleting.

## Batch Operations

```
> Add TypeScript types to all files in src/utils/
> Update import statements across the project
> Rename all occurrences of 'oldFunction' to 'newFunction'
```

## File Search

```
> Find all files that import the auth module
> Search for TODO comments in the codebase
> List files modified in the last commit
```

## Best Practices

- Review changes before approving - Always check proposed edits
- Use version control - Commit before major changes
- Be specific about file paths - Avoid ambiguity
- Break large operations into steps - Easier to review and revert
