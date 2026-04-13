# Source-Analysis / Voice

> 来源: claudecn.com

# Voice

Push-to-talk voice input — Claude Code builds a complete voice channel from microphone to model input through native audio modules, STT streaming, and OAuth gating.

## Core Question

Enabling voice input for a CLI tool is not about “how to record audio” but “how to reliably acquire audio streams across platforms, transcribe in real time, and integrate with the existing permission system.”

## Subsystem Overview

| Metric | Value |
| --- | --- |
| **Core service file** | `voice.ts` (526 lines) |
| **Maturity** | Emerging |
| **Gate control** | GrowthBook (`tengu_amber_quartz_disabled`) + Anthropic OAuth |
| **Native dependency** | `vendor/audio-capture/` — cpal native module |

## Architecture

| Component | File | Responsibility |
| --- | --- | --- |
| **Recording service** | `src/services/voice.ts` (526 lines) | Wraps cpal native module (macOS/Linux/Windows), falls back to SoX `rec` / ALSA `arecord` |
| **STT stream** | `src/services/voiceStreamSTT.ts` | Connects to `claude.ai` `voice_stream` endpoint for real-time speech-to-text |
| **Keywords** | `src/services/voiceKeyterms.ts` | Voice command keyword matching |
| **Gate** | `src/voice/voiceModeEnabled.ts` | GrowthBook + OAuth dual check |
| **Command entry** | `src/commands/voice/` | `/voice` command registration |
| **UI integration** | `useVoice.ts`, `useVoiceEnabled.ts`, `useVoiceIntegration.tsx` | React-side state and rendering |

```
Speech-to-Text → Audio Capture → Gate Layer → Interaction Layer → useVoice.ts → Push-to-talk → /voice command → GrowthBook → tengu_amber_quartz_disabled → Anthropic OAuth → Strong binding → cpal Native Module → audio-capture.node → Fallback → SoX rec / ALSA arecord → voiceStreamSTT.ts → voice_stream endpoint → voiceKeyterms.ts → Keyword matching
```

## Key Design Decisions

### Lazy Native Module Loading

`audio-capture.node` links CoreAudio.framework; synchronous `dlopen` blocking can reach ~8 seconds (cold start). Therefore it delays until the first voice keypress rather than preloading. This is a typical **startup time vs first-use latency** trade-off: sacrificing first-use responsiveness for zero overhead in all non-voice scenarios.

### OAuth Strong Binding

The `voice_stream` endpoint is only available through `claude.ai`. This means API Key, Bedrock, Vertex, and Foundry users cannot use voice. Voice is strongly bound to Anthropic’s own authentication system — likely for STT service cost and compliance reasons.

### Cross-Platform Audio

| Platform | Primary | Fallback |
| --- | --- | --- |
| **macOS** | cpal native module (CoreAudio) | SoX `rec` |
| **Linux** | cpal native module (ALSA/PulseAudio) | ALSA `arecord` |
| **Windows** | cpal native module (WASAPI) | — |

Fallback ensures voice remains functional even when native module loading fails (permission issues, missing dependencies) — just with potentially slightly degraded audio quality.

### Push-to-talk Mode

Voice input uses Push-to-talk (hold to record, release to send), not continuous listening. Silence detection threshold is 2.0 seconds / 3%. This design avoids the privacy and resource consumption concerns of “always listening.”

## Gate Mechanism

Voice Surface has triple gating:

- GrowthBook remote switch: tengu_amber_quartz_disabled can be shut off server-side at any time
- OAuth check: Only Anthropic OAuth-authenticated users can use it
- Feature Flag: VOICE_MODE (46 references) gates voice-related code paths
If any layer check fails, voice doesn’t appear in the UI or command list.

## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Layered fallback** | Native module → system tool → degradation notice — each layer has a clear fallback path |
| **Lazy-load heavy resources** | Don’t load potentially 8-second-blocking native dependencies at startup |
| **Auth-bound capabilities** | Bind high-cost capabilities (STT) to authentication to control server resource consumption |
| **Push-to-talk** | More energy-efficient, more private than continuous listening, and users feel more in control |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/services/voice.ts` | Recording service core (526 lines) |
| `src/services/voiceStreamSTT.ts` | Speech-to-text stream |
| `src/services/voiceKeyterms.ts` | Keyword matching |
| `src/voice/voiceModeEnabled.ts` | Gate logic |
| `src/commands/voice/` | Command entry |
| `src/hooks/useVoice.ts` | React Hook |
| `vendor/audio-capture/` | Audio capture native binary |

## Further Reading

- Signals & Extensions — Voice maturity assessment
- Architecture Map — Voice in the six-layer structure
- Computer Use — Another native-module-dependent capability
