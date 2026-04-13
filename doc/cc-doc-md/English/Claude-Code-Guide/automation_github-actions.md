# Claude-Code / Automation / Github-Actions

> 来源: claudecn.com

# GitHub Actions

Claude Code GitHub Actions brings AI-powered automation to your GitHub workflow. With a simple `@claude` mention in any PR or issue, Claude can analyze code, create pull requests, implement features, and fix bugs.

## Features

- Instant PR creation: Describe what you need, Claude creates complete PR
- Automated code implementation: Turn issues into working code with one command
- Follows your standards: Respects CLAUDE.md guidelines and code patterns
- Secure by default: Code stays on GitHub runners
---

## Quick Setup

### Option 1: Auto Install (Recommended)

In Claude Code terminal:

```bash
/install-github-app
```

This guides you through GitHub App installation and secrets configuration.

### Option 2: Manual Setup

- Install Claude GitHub App: https://github.com/apps/claude
- Add API Key: Settings → Secrets → Actions, add ANTHROPIC_API_KEY
- Create workflow .github/workflows/claude.yml:
```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

---

## Usage Examples

### In Issue or PR Comments

```
@claude implement this feature based on the issue description
@claude how should I implement user authentication for this endpoint?
@claude fix the TypeError in the user dashboard component
```

### Using Slash Commands

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: "/review"
    claude_args: "--max-turns 5"
```

---

## Configuration Parameters

| Parameter | Description | Required |
| --- | --- | --- |
| `prompt` | Instructions for Claude | No* |
| `claude_args` | CLI arguments | No |
| `anthropic_api_key` | API key | Yes** |
| `trigger_phrase` | Custom trigger (default “@claude”) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |
*Optional when responding to mentions
**Not required for Bedrock/Vertex

### Common claude_args

```yaml
claude_args: "--max-turns 5 --model claude-sonnet-4-5-20250929"
```

---

## CLAUDE.md Configuration
Create `CLAUDE.md` in repository root to define:

- Code style guidelines
- Review criteria
- Project-specific rules
Claude follows these guidelines when creating PRs.

---

## Cloud Providers

### AWS Bedrock

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: us-west-2

- uses: anthropics/claude-code-action@v1
  with:
    use_bedrock: "true"
    claude_args: '--model us.anthropic.claude-sonnet-4-5-20250929-v1:0'
```

### Google Vertex AI

```yaml
- uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
    service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

- uses: anthropics/claude-code-action@v1
  with:
    use_vertex: "true"
    claude_args: '--model claude-sonnet-4@20250514'
```

---

## Cost Optimization

- Use specific @claude commands to reduce API calls
- Configure --max-turns to limit iterations
- Set workflow timeouts to avoid runaway jobs
- Use concurrency controls for parallel runs
---

## Troubleshooting
**Claude not responding?**

- Verify GitHub App is installed
- Check workflows are enabled
- Confirm API key in secrets
- Ensure comment contains @claude (not /claude)
**Authentication errors?**

- Validate API key permissions
- Check Bedrock/Vertex credentials
- Verify secret names in workflow
