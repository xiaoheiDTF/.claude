# Claude-Code / Plugins / By-Use

> 来源: claudecn.com

# Choose plugins by job

The slowest way to use the official plugin directory is to browse it like a long list. A faster approach is to choose by the job you are trying to improve.

This page does not repeat the directory. It reorganizes official plugins into practical lanes so you can answer one question first:

- what kind of work are you trying to improve right now?
If you still need the basic mental model, start with [Understand plugins first](overview/). If you already know you want to start from the official directory but do not know which plugins to try first, start here.

## Choose by the problem you want to solve
[Setup and automation recommendationsFor teams beginning to systematize Claude Code
](#start-with-setup-and-automation-recommendations)[Review and quality gatesFor teams that want stronger review and risk control
](#stabilize-review-and-quality-gates-first)[Feature workflow and executionFor teams that want better discovery, design, and delivery flow
](#make-feature-execution-more-consistent)[Language intelligence and toolingFor projects that need stronger TypeScript, Python, Rust, and related support
](#add-language-intelligence-and-local-tooling)[Design and output styleFor frontend, teaching, and explanation-heavy work
](#improve-design-and-output-style)[Plugin and MCP buildingFor teams ready to package their own reusable capability
](#build-your-own-plugin-or-mcp-capability)

## Start with setup and automation recommendations

This lane fits teams that are taking Claude Code seriously for the first time but still do not know which automations are worth adding first.

Start with:

- claude-code-setup
- hookify
- claude-md-management
### What each one helps with

- claude-code-setup: scans a codebase and recommends the highest-value hooks, skills, subagents, commands, and MCP connections
- hookify: turns “I do not want this mistake again” into hook rules without hand-editing complex config
- claude-md-management: helps maintain project memory and CLAUDE.md entry points
## Stabilize review and quality gates first

If your main problem is no longer “how do we use Claude Code?” but “how do we keep low-quality changes out of the main line?”, this is the better starting group.

Start with:

- code-review
- pr-review-toolkit
### How to think about the split

- code-review is the more standardized review lane: parallel agents, confidence filtering, and explicit CLAUDE.md compliance checks
- pr-review-toolkit is the more composable lane: test quality, silent failures, type design, comment quality, and simplification can be pulled in by need
## Make feature execution more consistent

If your main issue is that feature work drifts or jumps too quickly into implementation, this group is more valuable than a random collection of helper plugins.

Start with:

- feature-dev
- commit-commands
### What is worth borrowing here

- feature-dev: turns discovery, codebase exploration, architecture design, implementation, and review into a clearer path
- commit-commands: improves consistency around commit flow and change description
## Add language intelligence and local tooling

If you already know the missing piece is language-service support, the best move is usually to add that directly instead of starting with heavier workflow plugins.

Typical official plugins in this lane include:

- typescript-lsp
- pyright-lsp
- rust-analyzer-lsp
- gopls-lsp
- clangd-lsp
- ruby-lsp
- php-lsp
- swift-lsp
- kotlin-lsp
- csharp-lsp
- jdtls-lsp
- lua-lsp
These are most useful when you want stronger definition lookup, references, diagnostics, and local code intelligence inside daily development.

## Improve design and output style

If the main concern is frontend quality, explanation style, or teaching-oriented output, this lane is the better match.

Start with:

- frontend-design
- explanatory-output-style
- learning-output-style
- playground
These plugins help more with presentation quality and working style than with governance or project structure.

## Build your own plugin or MCP capability

Once you know existing plugins are not enough and you are ready to package team capability, move into this lane.

Start with:

- plugin-dev
- mcp-server-dev
- skill-creator
- agent-sdk-dev
### What each lane helps with

- plugin-dev: building and packaging Claude Code plugins
- mcp-server-dev: designing and implementing MCP servers, including path selection across remote HTTP, MCP apps, MCPB, and local stdio
- skill-creator: creating, improving, and evaluating Skills
- agent-sdk-dev: deeper Agent SDK implementation work
## Recommended minimum bundles

### Early team setup

- claude-code-setup
- hookify
- code-review
### Quality-first workflow

- code-review
- pr-review-toolkit
- one LSP plugin for the team’s primary language
### Capability packaging

- plugin-dev
- mcp-server-dev
- skill-creator
## A simple decision rule

If your current problem is “we do not know which automation to add first,” start with setup and automation recommendations.

If your problem is “change quality is unstable,” start with review and quality gates.

If your problem is “feature work keeps drifting,” start with feature workflow and execution.

If your problem is “editing and diagnostics are weak,” start with language intelligence and local tooling.

If your problem is “existing capability is not specific enough for our team,” move into plugin and MCP building.

## Next steps

- Continue with Choose plugin sources
- If you are ready to install and validate, go to Discover and install plugins
- If you need to build your own, continue with Create Plugins
