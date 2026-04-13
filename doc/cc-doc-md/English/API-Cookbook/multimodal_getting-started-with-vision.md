# Cookbook / Multimodal / Getting-Started-With-Vision

> 来源: claudecn.com

# Getting started with vision

Shows the simplest way to pass images into Claude (example uses image URLs).

- Upstream notebook: multimodal/getting_started_with_vision.ipynb
## What to focus on

- Message content blocks for images
- Keeping image + instruction tightly scoped
- When to switch from URL-based input to base64 (see vision + tools)
## Run locally

```bash
make test-notebooks NOTEBOOK=multimodal/getting_started_with_vision.ipynb
```

## Related

- Vision + tools (base64 input): ../tool-use/vision-with-tools
