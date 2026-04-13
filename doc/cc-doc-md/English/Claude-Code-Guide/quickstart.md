# Claude-Code / Quickstart

> 来源: claudecn.com

# Claude Code Quickstart

Welcome to the Claude Code quickstart guide!

This guide will help you start using the AI-powered coding assistant in minutes. You’ll learn how to use Claude Code to complete common development tasks.

## Before You Begin

Make sure you have:

- An open terminal or command prompt
- A code project to work with
- A Claude.ai (recommended) or Claude Console account
## Step 1: Install Claude Code

### NPM Installation

If you have Node.js 18 or higher installed:

```sh
npm install -g @anthropic-ai/claude-code
```

### Native Installation
Alternatively, try our new native installation (currently in Beta).**Homebrew (macOS, Linux):**

```sh
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

**Windows CMD:**

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

## Step 2: Log In to Your Account
Claude Code requires an account to use. When you start an interactive session with the `claude` command, you’ll need to log in:

```bash
claude
# You'll be prompted to log in on first use
```

```bash
/login
# Follow the prompts to log in with your account
```

You can log in with either:

- Claude.ai (subscription plans - recommended)
- Claude Console (API access with prepaid credits)
After logging in, your credentials are stored so you won’t need to log in again.
When you authenticate Claude Code with a Claude Console account for the first time, a workspace called "Claude Code" is automatically created for you. This workspace provides centralized cost tracking and management for all Claude Code usage across your organization.
You can have both account types under the same email address. If you need to log in again or switch accounts, use the `/login` command in Claude Code.
## Step 3: Start Your First Session

Open a terminal in any project directory and launch Claude Code:

```bash
cd /path/to/your/project
claude
```

You’ll see the Claude Code welcome screen with your session info, recent conversations, and latest updates. Type `/help` to see available commands, or type `/resume` to continue a previous conversation.
After logging in (Step 2), your credentials are stored on your system. Learn more at [Credential Management](/en/docs/claude-code/iam/#credential-management).
## Step 4: Ask Your First Question

Let’s start by understanding your codebase. Try one of these:

```
> What does this project do?
```

Claude will analyze your files and provide a summary. You can also ask more specific questions:

```
> What technologies does this project use?
```

```
> Where is the main entry point?
```

```
> Explain the folder structure
```

You can also ask about Claude’s own capabilities:

```
> What can Claude Code do?
```

```
> How do I use slash commands in Claude Code?
```

```
> Can Claude Code work with Docker?
```

Claude Code reads your files as needed—you don't need to manually add context. Claude can also access its own documentation and answer questions about its features and capabilities.
## Step 5: Make Your First Code Change
Now let’s have Claude Code do some actual coding. Try a simple task:

```
> Add a hello world function to the main file
```

Claude Code will:

- Find the appropriate file
- Show you the proposed changes
- Ask for your approval
- Make the editClaude Code always asks permission before modifying files. You can approve individual changes or enable "accept all" mode for the session.
## Step 6: Use Git in Claude Code

Claude Code makes Git operations conversational:

```
> What files have I changed?
```

```
> Commit my changes with a descriptive message
```

You can also prompt for more complex Git operations:

```
> Create a new branch called feature/quickstart
```

```
> Show the last 5 commits
```

```
> Help me resolve merge conflicts
```

## Step 7: Fix Bugs or Add Features
Claude excels at debugging and feature implementation.

Describe what you want to achieve in natural language:

```
> Add input validation to the user registration form
```

Or fix existing issues:

```
> There's a bug where users can submit empty forms—fix it
```

Claude Code will:

- Locate relevant code
- Understand context
- Implement the solution
- Run tests if available
## Step 8: Try Other Common Workflows

There are many ways to collaborate with Claude:

**Refactor Code**

```
> Refactor the authentication module to use async/await instead of callbacks
```

**Write Tests**

```
> Write unit tests for the calculator functions
```

**Update Documentation**

```
> Update the README with installation instructions
```

**Code Review**

```
> Review my changes and suggest improvements
```

**Remember**: Claude Code is your AI pair [ programmer](#). Talk to it like you would a helpful colleague—describe what you want to achieve, and it will help you get there.
## Essential Commands
Here are the most important commands for daily use:

| Command | Function | Example |
| --- | --- | --- |
| `claude` | Start interactive mode | `claude` |
| `claude "task"` | Run one-off task | `claude "fix build errors"` |
| `claude -p "query"` | Run one-off query, then exit | `claude -p "explain this function"` |
| `claude -c` | Continue recent conversation | `claude -c` |
| `claude -r` | Resume previous conversation | `claude -r` |
| `claude commit` | Create Git commit | `claude commit` |
| `/clear` | Clear conversation history | `> /clear` |
| `/help` | Show available commands | `> /help` |
| `exit` or Ctrl+C | Exit Claude Code | `> exit` |

See the [CLI Reference](https://docs.claude.com/en/docs/claude-code/cli-reference) for the complete list of commands.

## Beginner Pro Tips
Don't say: "Fix the bug"
```
Try saying: "Fix the login bug where users see a blank screen after entering incorrect credentials"
```
Break complex tasks into multiple steps:
```
```
> 1. Create a new database table for user profiles
```

```
> 2. Create an API endpoint to fetch and update user profiles
```

```
> 3. Build a web page that allows users to view and edit their information
```
```
Before making changes, let Claude understand your code:
```
```
> Analyze the database schema
```

```
> Build a dashboard showing the most returned products by our UK customers
```
```
* Press `?` to see all available keyboard shortcuts
* Use Tab for command completion
* Press ↑ to see command history
* Type `/` to see all slash commands
## What’s Next?

Now that you know the basics, explore more advanced features:
[WorkflowsStep-by-step guides for common tasks
](https://claudecn.com/en/docs/claude-code/workflows/)[CLI ReferenceMaster all commands and options
](https://docs.claude.com/en/docs/claude-code/cli-reference)[SettingsCustomize Claude Code for your workflow
](https://claudecn.com/en/docs/claude-code/reference/settings/)

## Get Help

- In Claude Code: Type /help or ask “How do I…”
- Documentation: You’re here! Browse other guides
- Community: Join our Discord for tips and support
