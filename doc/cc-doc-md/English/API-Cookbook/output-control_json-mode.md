# Cookbook / Output-Control / Json-Mode

> 来源: claudecn.com

# JSON mode

Prompting patterns for consistently producing JSON outputs (and when to prefer tool-based schemas instead).

- Upstream notebook: misc/how_to_enable_json_mode.ipynb
## What to focus on

- Treat output shape as a contract (keys, types, omissions)
- Handling malformed JSON (retry/repair strategies)
- When to switch to tool schemas for hard guarantees
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/how_to_enable_json_mode.ipynb
```

## Related

- Tool-based JSON extraction: ../tool-use/extracting-structured-json
