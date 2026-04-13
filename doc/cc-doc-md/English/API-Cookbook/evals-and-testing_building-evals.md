# Cookbook / Evals-And-Testing / Building-Evals

> 来源: claudecn.com

# Building evals

Introduces core eval components (code-based grading, human grading, model-based grading) and how they fit into an iteration loop.

- Upstream notebook: misc/building_evals.ipynb
## What to focus on

- Defining metrics that match product requirements
- Separating dataset creation from scoring logic
- Making evals runnable in CI (fast/targeted)
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/building_evals.ipynb
```
