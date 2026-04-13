# Cookbook / Integrations-And-Ops / Pinecone-Rag

> 来源: claudecn.com

# RAG using Pinecone

An end-to-end RAG example integrating with Pinecone as the vector database.

- Upstream notebook: third_party/Pinecone/rag_using_pinecone.ipynb
## What to focus on

- Data ingestion and indexing choices
- Retrieval + answer synthesis wiring
- Operational concerns: cost, latency, and refresh strategy
## Run locally

```bash
make test-notebooks NOTEBOOK=third_party/Pinecone/rag_using_pinecone.ipynb
```
