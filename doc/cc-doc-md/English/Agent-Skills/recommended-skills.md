# Agent-Skills / Recommended-Skills

> 来源: claudecn.com

# Claude Skills Practical Guide

Skills are instruction packages that Claude loads dynamically — a folder containing `SKILL.md`, scripts, and reference materials. When Claude detects a relevant task, it reads and follows these instructions automatically. This mechanism enables the same Claude to perform at specialist level across different domains.

As of the 2026-04-07 sync snapshot, Anthropic’s [official repository](https://github.com/anthropics/skills) contains 17 top-level Skills directories across four capability groups plus one meta skill.

## Creative & Design

### frontend-design

Breaks the “every AI page looks the same” pattern. Requires Claude to commit to a bold aesthetic direction before writing code — brutalist, retro-futuristic, maximalist, organic/natural, luxury/refined — then enforces that direction across typography, color, spacing, animation, and spatial composition. Explicitly bans overused fonts like Inter, Roboto, and Arial, forcing distinctive pairings. Supports HTML/CSS/JS, React, Vue, and other major frameworks.

**Use cases:** Websites, landing pages, dashboards, React components, or any frontend interface that needs elevated design quality.

```bash
/install anthropics/skills/frontend-design
```

### canvas-design
Generates visual artwork on PDF or PNG canvases through code. Two-phase workflow: first outputs a “design philosophy” document (.md) defining the aesthetic movement’s core principles, then expresses it visually with original designs. Strictly avoids copying existing artists’ work.

**Use cases:** Poster design, cover art, data visualization graphics, brand visual assets.

```bash
/install anthropics/skills/canvas-design
```

### algorithmic-art
Generates algorithmic art through p5.js: geometric patterns, flow fields, particle systems, and fractals. Outputs three file types: algorithmic philosophy document (.md), interactive viewer (.html), and generative algorithm (.js). Uses seeded randomness for reproducibility with interactive parameter exploration.

**Use cases:** Generative art creation, procedural visual assets, technical team branding elements.

```bash
/install anthropics/skills/algorithmic-art
```

### theme-factory
Provides 10 curated professional theme systems, each with carefully selected color palettes and font pairings. Applicable to slides, docs, reports, HTML landing pages, or any artifact. Also supports on-the-fly theme generation from input keywords.

**Use cases:** Quick visual consistency for UI components, presentations, and marketing pages.

```bash
/install anthropics/skills/theme-factory
```

## Document Processing
The four document Skills power Claude.ai’s document creation features (source-available license). Without them, Claude writes ad-hoc scripts for format handling with inconsistent results; with them, it follows production-tested standard pipelines.

### docx

Create, read, and edit Word documents. Treats .docx as ZIP/XML structures under the hood, supporting table of contents generation, headers/footers, image insertion, tracked changes, find-and-replace, and other advanced features. Production output requires zero formatting errors.

**Use cases:** Technical reports, memos, contract templates, automated project documentation.

```bash
/install anthropics/skills/docx
```

### xlsx
Complete pipeline for Excel and CSV/TSV files. Requires zero formula errors (no #REF!, #DIV/0!, etc.), professional fonts, chart generation, conditional formatting, and pivot table support. Handles messy raw data files with malformed rows and misplaced headers.

**Use cases:** Data cleaning, financial modeling, report generation, cross-format conversion.

```bash
/install anthropics/skills/xlsx
```

### pdf
Full-lifecycle PDF processing: text extraction, merge/split, page rotation, watermarks, form filling, encryption/decryption, image extraction, and OCR for scanned documents. Built on Python toolchain (pypdf, pymupdf, etc.).

**Use cases:** Batch PDF processing, contract signing workflows, scanned document digitization.

```bash
/install anthropics/skills/pdf
```

### pptx
Read, create, and edit PowerPoint presentations. Supports both template-based and from-scratch creation, handling master layouts, speaker notes, and comments. Integrates with `markitdown` for text extraction from .pptx files.

**Use cases:** Project reports, pitch decks, training materials, automated meeting presentations.

```bash
/install anthropics/skills/pptx
```

These four Skills chain naturally: extract from PDF → analyze in Excel → generate Word report → create PPT presentation.

## Development & Technical

### mcp-builder

Guides Claude through building production-quality MCP (Model Context Protocol) Servers. Covers the full four-phase workflow: deep API research, schema design, tool implementation, and evaluation testing. Recommends TypeScript + Streamable HTTP with complete reference implementations in both Python and TypeScript. Emphasizes tool naming discoverability, context management, actionable error messages, and tool annotations (readOnlyHint, destructiveHint, etc.).

**Use cases:** Integrating external APIs/services with Claude, building custom MCP Servers, expanding Claude’s tool ecosystem.

```bash
/install anthropics/skills/mcp-builder
```

### claude-api
Build LLM-powered applications with the Claude API or Agent SDK. Auto-detects project language (Python / TypeScript / Java / Go / Ruby / C# / PHP / cURL) and loads matching code examples and SDK patterns. Includes model selection decision tree, Adaptive Thinking configuration (recommended for Opus 4.6 / Sonnet 4.6), Prompt Caching prefix-stability design, Compaction for long conversations, and Tool Runner automatic loop handling.

**Use cases:** Chatbots, multi-step workflows, custom agents, batch processing pipelines.

```bash
/install anthropics/skills/claude-api
```

### webapp-testing
Playwright-based testing for local web applications. Provides `with_server.py` for server lifecycle management with multi-server parallel startup. Core pattern: reconnaissance-then-action — wait for `networkidle`, screenshot to identify selectors, then execute interactions. Includes example patterns: element discovery, static HTML automation, console log capture.

**Use cases:** Frontend functional verification, UI behavior debugging, browser screenshot comparison, automated regression testing.

```bash
/install anthropics/skills/webapp-testing
```

### web-artifacts-builder
Build complex, multi-component web artifacts in Claude.ai. Stack: React 18 + TypeScript + Vite + Tailwind CSS + shadcn/ui. Initialize with `init-artifact.sh`, bundle into a single HTML file with `bundle-artifact.sh`. Designed for complex artifacts requiring state management, routing, or shadcn/ui components.

**Use cases:** Interactive prototypes, data dashboards, internal tool MVPs.

```bash
/install anthropics/skills/web-artifacts-builder
```

## Enterprise & Collaboration

### brand-guidelines
Loads official Anthropic brand colors and typography, applying them to any artifact — slides, docs, reports, HTML pages. Includes complete color system and type hierarchy definitions. Also serves as a template for creating similar brand guideline Skills for your own organization.

**Use cases:** Brand visual consistency, design specification documentation.

```bash
/install anthropics/skills/brand-guidelines
```

### internal-comms
Drafts internal communications: 3P updates (Progress / Plans / Problems), all-hands emails, project updates, change notifications, incident reports, FAQs. Adjusts tone and information density based on audience level. Provides structured templates and best practice references.

**Use cases:** Leadership reports, cross-team notifications, project status updates, incident post-mortems.

```bash
/install anthropics/skills/internal-comms
```

### doc-coauthoring
Structured collaborative document writing workflow. Three stages: **Context Gathering** (questions + info dump) → **Iterative Refinement** (per-section brainstorm → curate → draft → polish) → **Reader Testing** (validate with a context-free Claude to catch blind spots). Maintains document structure, cross-references, and terminology consistency.

**Use cases:** Technical white papers, product PRDs, design decision documents, RFCs, and other long-form documents requiring rigorous structure.

```bash
/install anthropics/skills/doc-coauthoring
```

### slack-gif-creator
Creates animated GIFs optimized for Slack chat. Handles Slack’s size constraints (Emoji GIF 128×128, message GIF 480×480) with validation tools and animation concept templates.

**Use cases:** Custom team emojis, milestone celebration animations, fun communication assets.

```bash
/install anthropics/skills/slack-gif-creator
```

## Meta Skill

### skill-creator
Build your own Skills. Complete workflow: intent capture → user interview → SKILL.md drafting → test case generation → parallel comparison runs (with-skill vs without) → quantitative benchmarking → human review (via built-in HTML viewer) → iterative improvement → trigger description optimization (automated via `run_loop.py`). Supports progressive disclosure architecture: SKILL.md < 500 lines, large reference materials loaded on demand.

**Use cases:** Packaging team coding standards, deployment workflows, ops checklists, personal workflows — the domains that generic Skills don’t cover.

```bash
/install anthropics/skills/skill-creator
```

## Installation

### Claude Code (recommended)
Install individually in Claude Code:

```bash
/install anthropics/skills/frontend-design
/install anthropics/skills/mcp-builder
/install anthropics/skills/skill-creator
/install anthropics/skills/docx
# ... same pattern for other Skills
```

### Claude.ai
Paid users have access to all official Skills without manual installation. Custom Skills are enabled by uploading `.skill` files.

### Claude API

Attach Skills via the [Skills API](https://docs.claude.com/en/api/skills-guide).

## Loading Architecture

Skills use three-level progressive disclosure — installing many Skills doesn’t significantly increase per-session cost:

| Level | Loaded When | Token Cost |
| --- | --- | --- |
| Metadata | Session start | ~100 tokens / Skill |
| SKILL.md body | Task match | < 5K tokens |
| Bundled resources | On demand | Unlimited |

Triggering is based on semantic matching of the `description` field — Claude evaluates whether the current task needs a Skill’s specialized capabilities, loading full instructions only on match.

## Next Steps
[Quick StartCreate your first custom Skill
](../quickstart/)[Official Examples17 production-grade Skills with source
](../examples/)[Best PracticesDesign principles for high-quality Skills
](../best-practices/)
