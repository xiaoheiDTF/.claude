# Cookbook / Integrations-And-Ops / Wolframalpha-Tool

> 来源: claudecn.com

# WolframAlpha as a tool

Uses the Wolfram Alpha LLM API as a tool, demonstrating tool use with an external computation/knowledge system.

- Upstream notebook: third_party/WolframAlpha/using_llm_api.ipynb
## What to focus on

- Tool interface design (inputs/outputs)
- Failure handling for external APIs
- Auditing and rate-limiting tool calls
## Run locally

```bash
make test-notebooks NOTEBOOK=third_party/WolframAlpha/using_llm_api.ipynb
```
