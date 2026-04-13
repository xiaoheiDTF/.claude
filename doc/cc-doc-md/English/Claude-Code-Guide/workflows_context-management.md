# Claude-Code / Workflows / Context-Management

> 来源: claudecn.com

# Context Management

Claude Code’s response quality depends on the context it receives.

## Initialize Project Understanding

Use `/init` to help Claude understand your project:

```
> /init
```

This generates or updates `CLAUDE.md` with:

- Project overview and tech stack
- Directory structure
- Common commands and conventions
## CLAUDE.md

`CLAUDE.md` is your project’s “memory file”. Claude automatically reads it for context.

**Create CLAUDE.md:**

```
> Create CLAUDE.md for this project
```

**Recommended contents:**

- Build and test commands
- Code style conventions
- Architecture decisions
- Common issues and solutions
## Stay Focused

Use `/clear` to clear context and start fresh:

```
> /clear
```

Use when:

- Starting a new task
- Too much irrelevant context accumulated
- Need Claude to re-evaluate the codebase
## Specify Files

Reference files directly using Tab completion:

```
> Look at src/auth/login.ts
```

## Provide External Resources
Let Claude fetch URL content:

```
> Read https://api.example.com/docs and implement the client
```

## Passing Data

### 1. Copy/Paste

```
> Here's the error log: [paste content]
```

### 2. Pipe Input

```bash
cat error.log | claude "Analyze this log"
git diff | claude "Review these changes"
```

### 3. Let Claude Use Tools

```
> Run tests and analyze failures
```

### 4. Read Files

```
> Read config/database.yml and explain the settings
```

## Interrupt and Redirect
Press **Escape** to interrupt Claude’s current operation.

```
> [Press Escape]
> Wait, I forgot to mention this is TypeScript. Please use type annotations.
```

## Best Practices

| Practice | Reason |
| --- | --- |
| Run `/init` before starting | Ensure Claude understands project |
| Use `/clear` after tasks | Avoid context pollution |
| Specify relevant files | Reduce Claude’s search time |
| Provide context in stages | Avoid information overload |
| Use Escape to correct course | Prevent going too far in wrong direction |
