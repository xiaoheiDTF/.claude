# Cookbook

> 来源: claudecn.com

# Cookbook

Cookbook works best when you want to learn by running, changing, and validating. It is not primarily a concept-first guide. It is a collection of runnable patterns built around real problems: you pick the example closest to your task, get it running, and then replace the data, tools, and constraints with your own.

If you are still unsure whether to start with `Claude Code`, `Quickstarts`, or `Cookbook`, check [Learning Paths](https://claudecn.com/en/docs/learning-paths/) first.

## When this section is most useful

- you want to validate whether a capability pattern is worth building
- you want to compare implementation paths instead of only reading abstract advice
- you already have a product idea and need a modifiable starting point
- you want experiments to gradually become repeatable engineering practice
## A better way to use cookbook material

### Start from one problem
Do not begin with “I should study the whole example library.” Begin with the problem in front of you: retrieval, tool use, agent orchestration, multimodal input, output control, or evaluation.

### Run a small example before replacing pieces

In the first pass, your job is to understand the main loop, not to rewrite everything immediately. Make the example run, then replace data, prompts, tools, and constraints one layer at a time.

### Add validation as soon as you start adapting

The moment you move from “reading an example” to “turning it into my own feature,” add a small evaluation set, assertions, or regression checks. Otherwise, it becomes easy to keep a notebook running without knowing whether quality got better or worse.

## What to prepare first

### Basic setup

- Python 3.11+
- a working Anthropic API key
- safe, repeatable test data
### The most common setup commands

```bash
uv sync --all-extras
cp .env.example .env
make test-notebooks
```

When you are ready to execute notebooks for real, add:

```bash
make test-notebooks-exec
```

Notebook-based work can mix experiment cost and data risk very quickly. Start with small samples, sanitized data, and a safe test environment.

## Choose a path by problem type

- need grounded answers over documents or data: see RAG & Retrieval
- need model-driven tool use and automation: see Tool Use
- need multi-step task decomposition and coordination: see Agent Patterns
- need image, screenshot, or document understanding: see Multimodal
- need tighter control over structure, citations, or cost: see Output Control
- need quality baselines and regression checks: see Evals & Testing
- need to connect examples to existing systems: see Integrations & Ops
## Suggested reading order
[Run your first example locallyBuild one reliable local loop before reading more examples
](repo-quickstart-and-structure/)[RAG & RetrievalMove from basic retrieval to stronger grounding and evaluation
](rag-and-retrieval/)[Tool UseLet models act through tools instead of stopping at text output
](tool-use/)[Agent PatternsBreak work into steps, roles, and control loops
](agent-patterns/)[MultimodalWork with images, screenshots, charts, and document transcription
](multimodal/)[Output ControlMake formatting, citations, caching, and throughput more predictable
](output-control/)[Evals & TestingCreate a quality baseline before examples become product features
](evals-and-testing/)[Integrations & OpsConnect examples to databases, vector stores, services, and cost tooling
](integrations-and-ops/)

## One principle that matters more than it looks
The value of an example is not that it decides the answer for you. The value is that it gives you a fast path to testing and refining your own implementation. The most useful question is usually not “what else can this example do?” but “which path should I borrow first for the problem I actually have?”
