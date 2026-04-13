# Cookbook / Agent-Patterns / Evaluator-Optimizer

> 来源: claudecn.com

# Evaluator-Optimizer

Use this pattern when a first draft is easy to produce, but consistent quality is hard to maintain. One role generates, another role judges, and the loop continues until the output crosses a useful threshold.

This is often a better fit than adding more prompt detail up front, because it turns quality control into an explicit step instead of a hope.

## What to focus on

- Separating “generate” from “judge”
- Stopping criteria (avoid infinite loops)
- How to turn evaluation into regression tests (see evals section)
## When it works well

- Outputs vary in quality even when the task looks stable
- You can describe what “better” means more easily than generating the perfect answer in one shot
- You want a path from manual review to repeatable evaluation
## If you want to reproduce it locally

Once your local Cookbook environment is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=patterns/agents/evaluator_optimizer.ipynb
```

## Related

- Evals overview: ../evals-and-testing
