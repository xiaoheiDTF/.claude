# Cookbook / Multimodal / Crop-Tool

> 来源: claudecn.com

# Crop tool for image analysis

Adds a crop tool to let Claude zoom into regions of interest, enabling a practical agentic loop for detailed image analysis.

- Upstream notebook: multimodal/crop_tool.ipynb
## What to focus on

- The “discover → crop → re-analyze” loop
- Tool design (coordinates, outputs) and safety
- When cropping beats longer prompts
## Run locally

```bash
make test-notebooks NOTEBOOK=multimodal/crop_tool.ipynb
```
