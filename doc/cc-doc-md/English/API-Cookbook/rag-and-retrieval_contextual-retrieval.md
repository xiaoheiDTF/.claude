# Cookbook / Rag-And-Retrieval / Contextual-Retrieval

> 来源: claudecn.com

# Contextual retrieval (contextual embeddings)

Use this pattern when basic retrieval can find roughly relevant text, but still misses the meaning you actually need because each chunk is too isolated from the rest of the document.

The core idea is to add lightweight context around each chunk so retrieval works on better-shaped units, then combine that with caching and hybrid search for better stability.

This is usually a second step after you have already proved that a simpler RAG baseline is directionally correct.

## What to focus on

- Chunk “situating context” prompts (short, retrieval-oriented)
- Prompt caching usage (cache_control: {type: \"ephemeral\"})
- Hybrid search patterns (BM25 + semantic retrieval)
## When it works well

- Relevant chunks are found, but lack enough surrounding meaning
- Similar fragments from different sections keep getting confused
- A plain RAG baseline works, but still feels brittle on real documents
## If you want to reproduce it locally

After your local Cookbook environment is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=capabilities/contextual-embeddings/guide.ipynb
```

The hybrid BM25 section uses Elasticsearch (example connects to `http://localhost:9200`).
