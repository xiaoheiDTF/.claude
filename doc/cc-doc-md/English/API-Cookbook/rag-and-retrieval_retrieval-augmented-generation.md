# Cookbook / Rag-And-Retrieval / Retrieval-Augmented-Generation

> 来源: claudecn.com

# Retrieval Augmented Generation

Use this page when the model does not know enough from the prompt alone and you need outside knowledge to be retrieved at runtime.

The practical value of this example is not just “adding retrieval.” It shows how to start with a small baseline, then improve quality in controlled steps: better chunking, better ranking, and explicit evaluation.

If you are new to retrieval systems, this is usually the right first stop before contextual retrieval, hybrid search, or knowledge graphs.

## What to focus on

- A minimal vector DB abstraction (embeddings, cache, persistence)
- How each retrieval upgrade changes recall/precision tradeoffs
- Adding evals so “better” becomes measurable
## When it works well

- Your answers need knowledge that does not fit in the prompt
- Source material changes more often than prompts should
- You want a clear baseline before moving to more complex retrieval designs
## If you want to reproduce it locally

After you have a working local Cookbook environment, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=capabilities/retrieval_augmented_generation/guide.ipynb
```

This example can require extra keys or services, such as an embeddings provider. Check the setup steps before running it against real data.
