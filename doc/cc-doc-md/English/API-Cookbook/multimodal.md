# Cookbook / Multimodal

> 来源: claudecn.com

# Multimodal: Vision, Charts, and Transcription

The multimodal (vision) notebooks cover three common workflows: **image understanding**, **structured extraction from images**, and **agentic loops around images** (e.g., a crop tool).

## Overview

Claude’s vision capabilities enable you to work with images in powerful ways:

- Image Understanding: Analyze and describe images, charts, and documents
- Structured Extraction: Extract data from forms, invoices, and visual content
- Agentic Vision Workflows: Combine vision with tools for complex multi-step tasks
This section provides 6 practical notebooks with copyable code examples.

## Recommended notebooks

### 1) Getting started: passing images to Claude
[Getting started with visionPass images (URL) into Claude
](getting-started-with-vision/)

### 2) Prompting for vision quality
[Best practices for visionPrompting patterns for multimodal reliability
](best-practices-for-vision/)

### 3) Focused tasks: charts, slides, forms
[Charts, graphs, and slide decksCharts and slides workflows
](charts-graphs-and-slide-decks/)[Transcribe documentsTyped, handwritten, forms → structured output
](transcribe-documents/)

### 4) Agentic: give Claude a crop tool
[Crop toolAdd a crop tool for detailed image analysis
](crop-tool/)

### 5) Vision + tools
Vision + tools is documented in Tool Use:

- ../tool-use/vision-with-tools
### 6) Sub-agents (optional)
[Using Haiku as a sub-agentPDF → images → extraction with a sub-agent
](using-sub-agents/)

## Practical tips

- Clean inputs beat longer prompts; crop/segment when details are dense.
- Prefer structured outputs (JSON) for extraction tasks, with validator + retry.
- Handle privacy and retention carefully: images often contain sensitive data.
