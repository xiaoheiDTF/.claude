# Cookbook / Output-Control

> 来源: claudecn.com

# Output Control: JSON, Citations, and Caching

Many production issues are output-side concerns: stable structure, traceable citations, predictable cost, and high-throughput batch processing.

## Recommended notebooks

### 1) Stable structured output
[JSON modePrompting patterns for consistent JSON output
](json-mode/)[Structured JSON + tool useUse tools as a schema contract
](../tool-use/extracting-structured-json)

### 2) Citations and traceability
[CitationsTraceable citations across document types
](citations/)

### 3) Cost & latency: prompt caching
[Prompt cachingCache-friendly prompt construction patterns
](prompt-caching/)[Speculative prompt cachingSpeculative caching comparisons
](speculative-prompt-caching/)

### 4) Throughput: batch processing
[Message Batches APIHigh-throughput batch workflows
](batch-processing/)

### 5) Safety: moderation filtering
[Moderation filterBuild a moderation filter with Claude
](moderation-filter/)

### 6) Long outputs (optional)
[Sampling past max tokensStrategies for very long outputs
](sampling-past-max-tokens/)

### 7) Prompt engineering workflow (optional)
[MetapromptPrompt templates + testing loop
](metaprompt/)

## Rules of thumb

- Treat format as an API contract: validate JSON and retry; don’t rely on prompts alone.
- Caching is a measured tradeoff: quantify hit-rate and savings before shipping.
- Batch needs observability: queueing, failures, retries, and result collection.
