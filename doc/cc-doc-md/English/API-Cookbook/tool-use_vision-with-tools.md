# Cookbook / Tool-Use / Vision-With-Tools

> 来源: claudecn.com

# Vision with tools

Combines vision input with tool use for structured extraction (nutrition label example uses base64 image input).

- Upstream notebook: tool_use/vision_with_tools.ipynb
## What to focus on

- Image content blocks (base64) + text instructions in one message
- Tool schema for extraction fields (treat it as an API contract)
- App-side validation and retries for extraction workflows
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/vision_with_tools.ipynb
```

## Related

- Vision overview: ../multimodal
