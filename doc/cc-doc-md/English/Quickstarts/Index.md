# Quickstarts

> 来源: claudecn.com

# Quickstarts

Quickstarts matter most when you either need to connect Claude to a real product for the first time, or you already know the product goal and need a runnable starting skeleton. Their real value is not “completing the demo once.” Their value is helping you choose the right product starting point much faster.

If you are not sure whether to start from `Quickstarts`, `Cookbook`, or `Claude Code`, see [Learning Paths](https://claudecn.com/en/docs/learning-paths/) first.

## Official project entry points
[Customer Support AgentConversational support, retrieval, and business workflow wrapping
](https://github.com/anthropics/claude-quickstarts/tree/main/customer-support-agent)[Financial Data AnalystChat-based analysis, file input, and chart generation
](https://github.com/anthropics/claude-quickstarts/tree/main/financial-data-analyst)[Browser Automation DemoDOM-aware browser automation and form interaction
](https://github.com/anthropics/claude-quickstarts/tree/main/browser-use-demo)[Computer Use DemoDesktop automation, screenshot understanding, and action chains
](https://github.com/anthropics/claude-quickstarts/tree/main/computer-use-demo)[Autonomous Coding AgentA multi-session coding-agent skeleton with persistent progress
](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding)[Agents ReferenceMinimal agent loop, tool loop, and MCP foundations
](https://github.com/anthropics/claude-quickstarts/tree/main/agents)

## What each project is best at teaching

| Official project | Best fit | What is worth extracting into the site | What to read next |
| --- | --- | --- | --- |
| Customer Support Agent | Support, knowledge assistants, internal help desks | Conversation UI, retrieval integration, response orchestration | [Cookbook](https://claudecn.com/en/docs/cookbook/) |
| Financial Data Analyst | Data Q&A, report explanation, chart generation | File input, chat-based analysis, chart rendering loop | [Cookbook](https://claudecn.com/en/docs/cookbook/) |
| Browser Automation Demo | Web navigation, form filling, extraction | DOM-aware tool design, browser action abstractions, safety boundaries | [Computer Use](https://claudecn.com/en/docs/computer-use/) |
| [ Computer](#) Use Demo | Desktop workflows, cross-window automation | Screenshot handling, coordinate scaling, container isolation, human confirmation | [Claude Code](https://claudecn.com/en/docs/claude-code/) |
| Autonomous Coding Agent | Long-running implementation work | Two-agent pattern, progress persistence, session continuation, command allowlists | [Claude Code](https://claudecn.com/en/docs/claude-code/) |
| Agents Reference | Learning the minimum agent model | Tool loops, message history, and MCP-connected foundations | [Claude Code Advanced](https://claudecn.com/en/docs/claude-code/advanced/) |

## Choose a starting point by goal

### Building a conversational product
If your focus is support, knowledge assistants, internal help desks, or question answering, start with `Customer Support Agent`. It is the closest official skeleton for conversation, retrieval, and reply structuring.

### Building an analysis product

If you need tables, charts, metrics, or trend explanation, start with `Financial Data Analyst`. It is the best fit for products where users ask questions in natural language and expect both charts and interpretation.

### Building browser automation

If the job lives inside web pages, forms, navigation, and extraction, start with `Browser Automation Demo`. The key lesson is DOM-aware action design, not just clicking on pixels.

### Building desktop automation

If the workflow spans desktop apps, system UI, or cross-window tasks, start with `Computer Use Demo`. The important lesson is not only capability, but also isolation, safety, and confirmation boundaries.

### Building a coding agent that keeps moving

If you care about long-running implementation work rather than one-shot answers, start with `Autonomous Coding Agent`. That is the right pattern when task breakdown, iteration, and progress across sessions matter.

### Learning agent fundamentals first

If you are still building your mental model of agents, start with `Agents Reference`. That foundation makes every other quickstart easier to understand and adapt.

## Do not copy quickstarts directly

Quickstarts work best as official product skeletons, not as pages to be translated line by line. A better extraction workflow is:

- identify the real product problem behind each project
- isolate the minimum loop: input, model, tools, output
- rewrite the engineering details into “what still needs to be added before production”
- keep only the necessary official code entry points and reading links
That produces pages that help readers decide what to study next instead of drowning them in README detail.

## A more effective way to use quickstarts

### Pick the closest match, not the biggest example

Do not compare everything at once. Choose the starting point that is closest to your product goal, then treat it as a minimal working skeleton.

### In the first pass, understand four things

- where user input enters
- where model output is produced
- how tools or data sources are connected
- how errors and edge cases are handled
### In the second pass, replace one layer at a time

Change only one dimension at a time: prompt, tool, data source, UI, or safety control. That makes it much easier to see what actually improved the result.

### In the third pass, add production essentials

Once the main interaction feels right, add authentication, logging, retries, monitoring, human review, and evaluation. Many projects stall not because the model is weak, but because these engineering layers were skipped.

## What you should prepare first

### Basic environment

- a working Anthropic API key
- Node.js LTS or Python 3.11+, depending on the example
- a small dataset or safe demo task you can repeat
### The most common environment variable

```bash
export ANTHROPIC_API_KEY="your-api-key"
```

If you are testing browser or desktop automation, start in a sandbox, test account, or isolated browser profile. Avoid learning against real production systems.

## Suggested learning paths

### First-time Claude API builders

Start with `Customer Support Agent` or `Financial Data Analyst`. The goal is to understand the core loop: user request, model reasoning, application response.

### Teams building automation tools

Start with `Browser Automation Demo`, then move to `Computer Use Demo`. That sequence gives you structure first, then open-ended UI control.

### Teams building agents or long-running task systems

Start with `Agents Reference` for tool loops and state handling, then move into `Autonomous Coding Agent` where longer execution chains matter.

## Checks to add before going live

- Are keys, cookies, and user data isolated correctly?
- Do you have retry and timeout handling?
- Are key actions logged?
- Do high-risk actions require human confirmation?
- Do you have a small evaluation set for the main task?
## Continue Reading

- Cookbook - runnable examples organized by problem type
- Claude Code - terminal-based development and automation workflows
- Agent Skills - reusable capabilities for stable, repeatable work
- Claude API Docs - official model and API reference
## Common questions

### Should I optimize structure first or just get something running?

Get the full loop running first, then improve structure. For most teams, seeing the end-to-end behavior is more valuable than designing perfect abstractions on day one.

### Can I ship a quickstart directly to production?

It is better to treat it as a product prototype or implementation skeleton. Before shipping, you still need security, monitoring, error handling, evaluation, and permission controls.

### What if I am not sure which kind of product I want yet?

Start with the category that is closest to your actual job to be done: conversation, analysis, browser automation, desktop automation, or long-running agents. Scenario fit matters more than picking the most feature-rich example.
