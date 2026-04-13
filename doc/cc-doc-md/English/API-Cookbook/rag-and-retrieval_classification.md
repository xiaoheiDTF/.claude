# Cookbook / Rag-And-Retrieval / Classification

> 来源: claudecn.com

# Classification

Use classification when your retrieval workflow must make decisions before it can answer well: which source to read, which tool to call, or which prompt strategy to apply.

In practice, this is less about taxonomy for its own sake and more about routing the next step correctly.

## What to focus on

- Label design and failure modes (ambiguous classes)
- Adding retrieval context when labels depend on domain knowledge
- Evaluating classifiers with realistic test sets
## When it works well

- The system must choose between several downstream paths
- Labels are actionable, not just descriptive
- You can collect realistic examples of borderline cases
## If you want to reproduce it locally

After your local Cookbook environment is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=capabilities/classification/guide.ipynb
```
