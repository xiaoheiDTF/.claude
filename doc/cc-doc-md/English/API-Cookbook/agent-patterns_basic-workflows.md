# Cookbook / Agent-Patterns / Basic-Workflows

> 来源: claudecn.com

# Basic workflows

This page is a good starting point if you want to compare a few small workflow shapes before committing to a larger agent design.

Think of it as a pattern sampler: simple sequences, split-and-merge flows, and lightweight structures you can reuse across very different tasks.

## What to focus on

- Reusable “workflow skeletons” you can apply across tasks
- Where to insert tools, retrieval, and evaluation
- Keeping prompts short by relying on structure
## When it works well

- You are still deciding between serial, parallel, or staged work
- You want a minimal pattern before adding tools or memory
- You need a reusable scaffold, not a domain-specific solution
## If you want to reproduce it locally

After your local Cookbook setup is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=patterns/agents/basic_workflows.ipynb
```
