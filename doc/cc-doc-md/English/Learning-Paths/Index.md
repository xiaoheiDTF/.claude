# Learning-Paths

> 来源: claudecn.com

# Learning Paths

If you read Claude material one repository at a time or one product surface at a time, it quickly becomes fragmented. A better approach is to identify your current stage first, then choose the right entry point for that stage.

This page turns the existing site into a small set of clear paths so you can decide:

- what to read first
- why it should come first
- where to go next after that
## Choose a path by your current goal
[Get Claude Code working in real lifeFor people who want Claude Code to become useful in daily work first
](#path-1-get-claude-code-working-in-real-life)[Build your first real applicationFor people who already have a product idea and need the right starting skeleton
](#path-2-build-your-first-real-application)[Turn repeated practice into team capabilityFor people thinking about reuse, plugins, rules, and shared workflows
](#path-3-turn-repeated-practice-into-team-capability)[Move from using capabilities to understanding the systemFor people who want runtime, tool, and harness-level understanding
](#path-4-move-from-using-capabilities-to-understanding-the-system)

## Path 1: Get Claude Code working in real life

This path is for readers who do not need complex integration yet. The immediate goal is to make Claude Code useful in real development work.

### Recommended order

- Claude Code Quickstart
- Claude Code Getting Started
- Workflows
- Practical Guides
### What this path is really about

- build a minimum working habit before studying every feature
- learn how to frame tasks clearly, provide context well, and verify changes
- get real code tasks done before you expand into more advanced surfaces
### Expected outcome

By the end of this path, you should be able to:

- ask Claude to read and modify existing codebases
- use Claude to debug build and test failures
- get better results with fewer prompts
- establish a reliable personal workflow
## Path 2: Build your first real application

This path is for readers who want more than terminal-side assistance. The goal is to place Claude inside an actual product, UI flow, or automation loop.

### Recommended order

- Quickstarts
- Cookbook
- Computer Use
- Extended Thinking
### Why this order works

`Quickstarts` answers “which product skeleton should I start from?”
`Cookbook` answers “which implementation pattern fits the problem in front of me?”
`Computer Use` and `Extended Thinking` help you decide when stronger interaction and reasoning surfaces are worth adding.

### If your goal is more specific

- for support or knowledge assistants: start from Quickstarts, then add retrieval and tool patterns from Cookbook
- for analysis and chart generation: start from the analysis-oriented quickstart, then add output control and evaluation patterns from Cookbook
- for browser or desktop automation: start from Quickstarts, then go deeper with Computer Use
### Expected outcome

You should be able to judge:

- which official starting point best fits your product
- what still separates a runnable demo from production
- which capabilities are worth validating first and which should not be introduced too early
## Path 3: Turn repeated practice into team capability

This path is for readers who are starting to repeat the same kinds of tasks and want to turn session knowledge into reusable team capability.

### Recommended order

- Agent Skills
- Claude Code Advanced
- Plugins
- Workflows
### What this path helps you answer

- what should become a Skill
- what should become a plugin
- what should stay in project-local configuration
- how Hooks, MCP, commands, and rules combine into a stable operating model
### A useful test

If something is only used occasionally by one person in one project, do not rush to package it. Once it becomes repeated, shared, and worth versioning, then it belongs in Skills, plugins, or team configuration.

### Expected outcome

You should be able to distinguish:

- temporary prompting vs reusable capability
- project-local configuration vs cross-project plugins
- one-off experience vs shared team workflow
## Path 4: Move from using capabilities to understanding the system

This path is for readers who already use Claude Code but want to understand why it is designed the way it is, and which patterns are worth migrating into their own agent systems.

### Recommended order

- Source Analysis Overview
- Claude Code Agent Loop
- Claude Code Advanced
- Plugins
### What this path is really about

- understand how tools, permissions, compaction, memory, commands, and extension surfaces fit together
- separate product features from harness mechanisms
- extract engineering principles from a mature system instead of only looking at visible features
### Who this is best for

- teams building internal agent platforms or engineering tools
- teams trying to operationalize Claude Code practices
- readers who want to understand why capability surfaces need governance and boundaries
## One simple decision rule

If you are still in the “make something work first” phase, prioritize `Quickstarts + Cookbook + Claude Code`.

If you are already in the “stabilize and reuse what works” phase, prioritize `Agent Skills + Plugins + Workflows`.

If you are asking “why is the system designed this way?”, move into `Source Analysis + Agent Loop + Advanced`.

## Recommended minimum bundles

### Minimum bundle for individual developers

- Claude Code Quickstart
- Quickstarts
- Cookbook
### Minimum bundle for product teams

- Quickstarts
- Cookbook
- Agent Skills
- Workflows
### Minimum bundle for platform or architecture teams

- Source Analysis
- Claude Code Advanced
- Plugins
- Agent Skills
## Next steps

If you want the shortest useful entry, start here:
[First time with Claude CodeBuild a minimum useful working pattern first
](https://claudecn.com/en/docs/claude-code/quickstart/)[Build a real applicationChoose the right official starting point by product goal
](https://claudecn.com/en/docs/quickstarts/)[Turn experience into capabilityMove into Skills, plugins, and shared workflows
](https://claudecn.com/en/docs/agent-skills/)[Understand the internal systemMove into runtime, tools, and governance boundaries
](https://claudecn.com/en/docs/source-analysis/)
