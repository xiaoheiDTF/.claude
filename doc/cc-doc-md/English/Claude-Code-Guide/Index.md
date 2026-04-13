# Claude-Code

> 来源: claudecn.com

# Claude Code

Claude Code is an AI-powered command-line development tool that completes coding, debugging, refactoring, and other development tasks through natural language conversations.

## Core Features

### 🚀 AI-Driven Development Experience

Complete development tasks through natural language conversations. Claude understands your intent without memorizing complex commands or APIs.

### 📁 Smart File Operations

Claude Code automatically reads and analyzes project files, understands code structure and context without manually adding files to conversations.

### 🔧 Git Integration

Conversational Git operations with intelligent commit message generation for easy version control tasks.

### 🎯 Precise Code Editing

Claude shows proposed changes and requests approval, ensuring every code change is under your control.

## Quick Navigation
[Quick StartGet started with Claude Code in 5 minutes
](quickstart/)[Common WorkflowsPractical development scenarios and tips
](workflows/)[Source AnalysisUnderstand Claude Code through the real release package and its code surfaces
](https://claudecn.com/en/docs/source-analysis/)[Plugin SystemExtend Claude Code functionality
](plugins/)[SubagentsUse subagents for complex tasks
](advanced/subagents/)

## Installation

### NPM Install

```bash
npm install -g @anthropic-ai/claude-code
```

### Native Install
**Homebrew (macOS, Linux):**

```bash
brew install --cask claude-code
```

**macOS, Linux, WSL:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell:**

```powershell
irm https://claude.ai/install.ps1 | iex
```

## Basic Usage

### Start Interactive Mode

```bash
claude
```

### Execute One-time Task

```bash
claude "fix the build error"
```

### Continue Last Conversation

```bash
claude -c
```

### Smart Code Commit

```bash
claude commit
```

## Use Cases

### Code Writing

```
> add a hello world function to main.py
```

### Code Debugging

```
> there's a bug where users can submit empty forms - fix it
```

### Code Refactoring

```
> refactor the authentication module to use async/await
```

### Test Writing

```
> write unit tests for the calculator functions
```

### Git Operations

```
> what files have I changed
> commit my changes with a descriptive message
```

## Next Steps

- Quick Start - 5-minute tutorial
- Common Workflows - Practical scenarios
- Source Analysis - Architecture, runtime, tools, commands, and signals
- CLI Reference - Complete command reference
## Related Resources

- Official Docs
- GitHub
- Discord Community
