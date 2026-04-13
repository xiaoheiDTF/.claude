# Cookbook / Integrations-And-Ops / Deepgram-Audio-Transcription

> 来源: claudecn.com

# Audio transcription with Deepgram

Transcribes audio using Deepgram and uses Claude to prepare follow-up questions (interview workflow example).

- Upstream notebook: third_party/Deepgram/prerecorded_audio.ipynb
## What to focus on

- Separation of concerns: transcription vs synthesis
- Handling timestamps and speaker turns
- Prompting for actionable outputs (questions, summaries)
## Run locally

```bash
make test-notebooks NOTEBOOK=third_party/Deepgram/prerecorded_audio.ipynb
```
