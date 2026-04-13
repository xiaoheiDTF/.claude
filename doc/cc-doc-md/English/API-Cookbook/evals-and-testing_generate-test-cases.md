# Cookbook / Evals-And-Testing / Generate-Test-Cases

> 来源: claudecn.com

# Generate synthetic test cases

Generates synthetic test data for a prompt template, useful for bootstrapping eval coverage.

- Upstream notebook: misc/generate_test_cases.ipynb
## What to focus on

- Treat prompt templates like code (inputs/outputs)
- Generating diverse edge cases (not just “happy paths”)
- Using the dataset for regression checks
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/generate_test_cases.ipynb
```
