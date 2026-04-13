# Cookbook / Integrations-And-Ops

> 来源: claudecn.com

# Integrations & Ops: Third Party, Fine-Tuning, and Cost Tracking

These cookbooks focus on putting Claude into real systems: **third-party integrations**, **cloud platform workflows** (e.g., Bedrock), and **usage/cost observability**.

## Overview

Building production applications with Claude requires more than just API calls:

- Integrations: Connect Claude with databases (Pinecone, MongoDB), search services (Wikipedia), and specialized tools (Wolfram Alpha, Deepgram)
- Cloud Platforms: Deploy on AWS Bedrock with fine-tuning capabilities
- Operations: Track usage, monitor costs, and set up observability for production workloads
## Third-party integrations
[Pinecone RAGRAG using Pinecone
](pinecone-rag/)[MongoDB RAGRAG using MongoDB
](mongodb-rag/)[LlamaIndex basic RAGBasic RAG pipeline with LlamaIndex
](llamaindex-basic-rag/)[Wikipedia searchIterative searching Wikipedia with Claude
](wikipedia-search/)[Wolfram Alpha toolUse WolframAlpha as a tool
](wolframalpha-tool/)[ElevenLabs voice assistantLow-latency voice assistant
](elevenlabs-voice-assistant/)[Deepgram transcriptionAudio transcription + question generation
](deepgram-audio-transcription/)

## Fine-tuning
[Finetuning on BedrockFine-tune Claude 3 Haiku on Amazon Bedrock
](finetuning-on-bedrock/)

Fine-tuning examples often involve sensitive datasets. Align on compliance, redaction, permissions, and retention before uploading data.

## Usage & cost observability
[Usage & cost Admin APIUsage/cost tracking scaffolding
](usage-cost-admin-api/)
This notebook is a good starting point for a minimal cost-tracking scaffold (grouping/filtering/pagination/export), before wiring into your own monitoring and alerting stack.
