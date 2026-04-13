# Cookbook / Evals-And-Testing

> 来源: claudecn.com

# Quality & Evals: Testing Data and Tool Evaluation

Cookbooks is valuable not just for runnable examples, but also for “how to evaluate and align quality” with concrete, executable recipes.

## Recommended notebooks

### 1) Building evals
[Building evalsCore eval components (code/human/model)
](building-evals/)

### 2) Synthetic test cases
[Generate synthetic test casesGenerate test data for prompt templates
](generate-test-cases/)

### 3) Tool evaluation
[Tool evaluationEvaluate tool calling behavior and loops
](tool-evaluation/)

### 4) Quality loops inside agents (optional)
Evaluator-Optimizer lives under Agent Patterns:

- ../agent-patterns/evaluator-optimizer
## How this fits repo guardrails

- Structure + reproducibility: make test-notebooks (fast, CI-friendly)
- Execution + regression: make test-notebooks-exec (slow, periodic)
Start with a minimal eval, then iterate on metrics, coverage, and failure diagnosis.
