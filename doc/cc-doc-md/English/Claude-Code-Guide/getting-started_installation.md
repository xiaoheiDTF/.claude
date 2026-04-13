# Claude-Code / Getting-Started / Installation

> 来源: claudecn.com

# Installation

This guide covers installing Claude Code on different systems.

## System Requirements

| Requirement | Description |
| --- | --- |
| **[ OS](#)** | macOS 10.15+, Ubuntu 20.04+/Debian 10+, Windows 10+ (via WSL2) |
| **Hardware** | 4GB+ RAM |
| **[ Software](#)** | Node.js 18+ |
| **Network** | Internet connection required |

## Installation Methods

### NPM Install (Recommended)

```bash
npm install -g @anthropic-ai/claude-code
```

### Homebrew

```bash
brew install --cask claude-code
```

### Script Install
**macOS, Linux, WSL:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell:**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**WinGet (Windows):**

```powershell
winget install Anthropic.ClaudeCode
```

## Verify Installation

```bash
claude --version
```

## VS Code Extension

- Open VS Code
- Press Cmd+Shift+X (macOS) or Ctrl+Shift+X (Windows/Linux)
- Search “Claude Code”
- Click Install
## First Launch and Authentication

```bash
claude
```

On first launch, Claude Code guides you through authentication:

- Choose authentication method (Anthropic API or Claude Pro/Max subscription)
- Complete login in browser
- Return to terminal, authentication completes automatically
## Troubleshooting

### Node.js Version Too Low

```bash
node --version
# If below 18, upgrade using nvm
nvm install 18
nvm use 18
```

### Permission Issues

```bash
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## Update Claude Code

```bash
# NPM
npm update -g @anthropic-ai/claude-code

# Homebrew
brew upgrade --cask claude-code
```
