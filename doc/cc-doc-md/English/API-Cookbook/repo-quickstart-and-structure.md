# Cookbook / Repo-Quickstart-And-Structure

> 来源: claudecn.com

# Run your first example locally

The goal of this page is simple: do not try to understand every example at once. First build one stable local loop. Once you can run, change, and validate one example repeatedly, the rest of the section becomes much easier to use.

## Step 1: prepare a safe local environment

### Basic requirements

- Python 3.11+
- uv
- a working ANTHROPIC_API_KEY
- a small, repeatable dataset
### The most common setup commands

```bash
uv sync --all-extras
cp .env.example .env
```

Then add your key in `.env`:

```bash
ANTHROPIC_API_KEY=your-api-key
```

## Step 2: check structure before full execution

### Fast structural checks

```bash
make test-notebooks
```

This is the better first move when you want to catch obvious issues such as broken setup, missing assumptions, or notebook structure problems.

### Run one target example only

```bash
make test-notebooks NOTEBOOK=tool_use/calculator_tool.ipynb
```

Focusing on one example is usually much more productive than running everything immediately.

### Execute notebooks for real only when needed

```bash
make test-notebooks-exec
```

Do this when you are confident the example direction is right and you are ready to evaluate real model behavior.

## Step 3: choose examples by problem, not curiosity

- need document grounding or search: see RAG & Retrieval
- need tool orchestration or automation: see Tool Use
- need multi-step task flows: see Agent Patterns
- need image, screenshot, or document understanding: see Multimodal
- need structured output, caching, or output constraints: see Output Control
- need regression and quality checks: see Evals & Testing
## Step 4: change one layer at a time

Use this order when adapting an example:

- replace the input data
- then adjust prompts or constraints
- then connect your own tools or systems
- only after that tune model, concurrency, and cost behavior
This makes it much easier to tell which layer actually changed the result.

## Common mistakes

### Starting with large datasets

This usually inflates debugging cost, API cost, and investigation complexity all at once.

### Changing too many things at once

If you change prompts, tools, data, and model behavior together, it becomes hard to identify the source of a problem.

### Skipping a small validation set

Once you adapt an example into your own feature, you need a fixed small set of checks. Otherwise you can keep a notebook running without knowing whether quality improved.

### Testing directly on real production data

Sanitize first, reduce scope first, and validate in a safe environment first. Early example work should minimize risk, not maximize realism.

## Final advice

The highest-leverage move is not “reading more examples.” It is turning one example into something you would actually maintain. Once that happens, the rest of the cookbook becomes much easier to apply.
