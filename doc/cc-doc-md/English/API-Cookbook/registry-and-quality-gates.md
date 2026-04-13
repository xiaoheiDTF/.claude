# Cookbook / Registry-And-Quality-Gates

> 来源: claudecn.com

# Registry & quality gates

This page covers:

- what registry.yaml is and why it’s more useful than a README list;
- what quality gates you should pass locally before opening a PR.
## 1) registry.yaml: a machine-readable cookbook index

The repo maintains notebook metadata in `registry.yaml`, validated by `.github/registry_schema.json`.

### 1.1 Required fields

Each entry must include:

- title
- path
- authors (GitHub usernames, which must exist in authors.yaml)
- date (YYYY-MM-DD)
- categories (>= 1 category, from the enum)
### 1.2 Category enum

Allowed categories currently include:

- Agent Patterns
- Claude Agent SDK
- Evals
- Fine-Tuning
- Multimodal
- Integrations
- Observability
- RAG & Retrieval
- Responses
- Skills
- Thinking
- Tools
### 1.3 Minimal entry example

```yaml
- title: Your Cookbook Title
  description: What users will build/learn in 1-2 sentences.
  path: tool_use/your_notebook.ipynb
  authors:
  - your-github-handle
  date: '2026-01-23'
  categories:
  - Tools
```

## 2) authors.yaml is the source of truth
`authors.yaml` stores display name / website / avatar. Sorting and validation scripts help keep it clean.

```bash
make sort-authors
```

## 3) Quality gates you should run locally

### 3.1 Code style & unit tests

```bash
make check
make test
```

### 3.2 Notebook structure tests

```bash
make test-notebooks NOTEBOOK=path/to/notebook.ipynb
```

The structure suite focuses on:

- fresh kernel execution counts (starting from 1)
- sequential execution order
- no error outputs
- no hardcoded secrets
- sensible dependency cells (pip install near the top)
### 3.3 Registry/Authors consistency

The repo provides `.github/scripts/verify_registry.py` to check:

- registry authors exist in authors.yaml
- registry paths exist
- schema validation
Some checks (GitHub handle / URL reachability) require network access; offline runs can focus on `schema/paths/registry`.

## 4) Claude Code slash commands for contributors

The `.claude/` folder defines slash commands for Claude Code:

- /add-registry
- /notebook-review
- /model-check
- /link-review
- /review-pr / /review-pr-ci
For notebook writing quality, `.claude/skills/cookbook-audit/style_guide.md` provides a clear rubric (problem-first framing, learning objectives, conclusions that map back, dotenv usage, MODEL constants, suppressing noisy installs, etc.).
