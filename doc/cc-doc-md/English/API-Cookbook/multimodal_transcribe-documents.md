# Cookbook / Multimodal / Transcribe-Documents

> 来源: claudecn.com

# Transcribe documents

Document transcription patterns across typed text, handwriting, and forms, including “unstructured → JSON”.

- Upstream notebook: multimodal/how_to_transcribe_text.ipynb
## What to focus on

- Choosing extraction targets (fields) before transcribing everything
- JSON as the default contract for form-like documents
- Dealing with low-quality scans (crop/segment first)
## Run locally

```bash
make test-notebooks NOTEBOOK=multimodal/how_to_transcribe_text.ipynb
```
