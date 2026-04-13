# Cookbook / Multimodal / Using-Sub-Agents

> 来源: claudecn.com

# Using a sub-agent (Haiku) for extraction

Demonstrates a sub-agent workflow: generate a focused extraction prompt, extract from PDFs (converted to images), and then produce a final response.

- Upstream notebook: multimodal/using_sub_agents.ipynb
## What to focus on

- Sub-agent division of labor (extract vs synthesize)
- Converting PDFs to images for robust extraction
- Keeping intermediate artifacts auditable
## Run locally

```bash
make test-notebooks NOTEBOOK=multimodal/using_sub_agents.ipynb
```
