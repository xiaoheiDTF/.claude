# Cookbook / Integrations-And-Ops / Elevenlabs-Voice-Assistant

> 来源: claudecn.com

# Low-latency voice assistant (ElevenLabs)

Builds a low-latency voice assistant by combining speech-to-text and text-to-speech with Claude.

- Upstream notebook: third_party/ElevenLabs/low_latency_stt_claude_tts.ipynb
## What to focus on

- Streaming and latency budgets
- Tooling for STT/TTS and retry behavior
- Safety controls for voice outputs
## Run locally

```bash
make test-notebooks NOTEBOOK=third_party/ElevenLabs/low_latency_stt_claude_tts.ipynb
```
