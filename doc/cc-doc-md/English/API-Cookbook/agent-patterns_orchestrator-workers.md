# Cookbook / Agent-Patterns / Orchestrator-Workers

> 来源: claudecn.com

# Orchestrator-Workers

Use this pattern when a task is too broad for one prompt, but still structured enough to split into clear sub-jobs. One role plans and delegates; other roles execute focused work and return bounded outputs.

The main value is not “more agents.” It is clearer division of responsibility, simpler prompts, and easier review points.

## What to focus on

- Task decomposition: what belongs in the orchestrator vs workers
- Interfaces between steps (inputs/outputs) as contracts
- Where to add evaluation or review gates
## When it works well

- The task can be divided into independent parts
- Each worker can return a small, checkable result
- You want parallelism without losing control of the final synthesis
## If you want to reproduce it locally

Once your local Cookbook environment is working, you can run the structure check for the matching example with:

```bash
make test-notebooks NOTEBOOK=patterns/agents/orchestrator_workers.ipynb
```
