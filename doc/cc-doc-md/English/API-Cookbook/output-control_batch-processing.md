# Cookbook / Output-Control / Batch-Processing

> 来源: claudecn.com

# Batch processing (Message Batches API)

High-throughput batch workflows: creating batches, monitoring progress, and retrieving results.

- Upstream notebook: misc/batch_processing.ipynb
## What to focus on

- Batch lifecycle (create → monitor → collect)
- Failure handling (partial failures, retries)
- Observability hooks (cost, latency, success rates)
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/batch_processing.ipynb
```
