# Claude-Code / Practical-Guides / Prompt-Tips

> 来源: claudecn.com

# Prompt Tips

Tips for writing effective prompts to get better results from Claude Code.

## Be Specific

**Instead of:**

```
> Fix the bug
```

**Try:**

```
> Fix the login bug where users see a blank screen after entering wrong credentials
```

## Provide Context

```
> This is a React project using TypeScript. Add form validation to the register page.
```

## Break Down Complex Tasks

```
> Step 1: Create the database table for user profiles
> Step 2: Create API endpoints for CRUD operations
> Step 3: Build the frontend form
```

## Use Examples

```
> Add error handling like we did in auth.ts
```

## Specify Output Format

```
> Generate a summary in bullet points
> Create a table comparing these options
```

## Ask Claude to Explain

```
> Explain your approach before making changes
> Walk me through what this code does
```

## Iterate and Refine
If results aren’t what you expected:

```
> That's not quite right. I meant [clarification]
> Can you try a different approach?
> Make it more concise
```

## Common Patterns

| Goal | Prompt |
| --- | --- |
| Explore | “What does this project do?” |
| Debug | “Why is this test failing?” |
| Implement | “Add [feature] to [component]” |
| Refactor | “Refactor to use [pattern]” |
| Review | “Review my recent changes” |
