# Cookbook / Rag-And-Retrieval / Summarization

> 来源: claudecn.com

# Summarization

Use summarization when raw source material is too long, too noisy, or too uneven to feed directly into later retrieval or decision steps.

Good summarization is not only shorter text. It is a stable information contract: what to keep, what to drop, and how much structure downstream steps can rely on.

## What to focus on

- Summary format as a contract (length, structure, exclusions)
- Using evals to catch hallucinations and omissions
- When summaries should become part of the retrieval index
## When it works well

- The source documents are long or inconsistent in structure
- Downstream steps benefit from a more regular representation
- You need summaries that can be checked, compared, and reused
## If you want to reproduce it locally

After your local Cookbook environment is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=capabilities/summarization/guide.ipynb
```
