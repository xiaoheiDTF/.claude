# Claude-Code / Advanced / Agent-Loop

> 来源: claudecn.com

# The Agent Loop Behind Claude Code (Understanding from Zero)

If you think of Claude Code as just a “coding CLI,” many of its capabilities seem like magic: it can read files, run commands, edit code, break down tasks, and stay on track during complex work.

But from an engineering perspective, the core is surprisingly simple: **Model + Tools + A Loop (Agent Loop)**. Understanding this loop helps you clearly see:

- When to let Claude “plan” first vs. “just do it”
- Why “explicit task tracking (Todo)” significantly reduces going off-track
- Why “subagents” improve exploration efficiency and context quality
- What roles Skills/MCP/Hooks play in the system
This explains the “principles” clearly and provides an executable learning path: each chapter introduces only one key mechanism, making it easy to build intuition and verify by reproduction.

## Target Audience

This is for you if you meet any of these criteria:

- Already use Claude Code for daily development but want to understand why it “behaves like an Agent”
- Need to integrate Claude API/Agent SDK into your product and want to grasp the core control flow first
- Want to solidify team best practices (rules, checks, knowledge) into reusable constraints
## Background & Concepts: What is an Agent Loop

The essence of an Agent Loop is a “tool-driven conversation loop”:

- Your application sends context (messages) and tool definitions (tools) to the model
- The model either outputs text or requests a tool call (tool_use)
- Your application executes the tool and sends the result back to the model (tool_result)
- Repeat until the model finishes (end_turn)
```python
while True:
    response = model(messages, tools)
    if response.stop_reason != "tool_use":
        return response.text
    results = execute(response.tool_calls)
    messages.append(results)
```

You can understand all behaviors in Claude Code like “read files/search/edit/run tests/commit Git” as: **the model continuously requesting tool calls within the loop**.

## Learning Path: v0->v4 (One Key Mechanism per Chapter)

- v0 (Bash Agent): Only 1 tool (bash), but can do complete “read/write/search/execute”, and even implement subagents via “recursive self-calls”
- v1 (Basic Agent): Adds clearer read/write/edit tools, structure closer to common production implementations
- v2 (Todo Agent): Adds TodoWrite, making plans visible, constraining, and trackable
- v3 (Subagent): Introduces Task/subagents, solving the “exploration pollutes main context” problem
- v4 (Skills Agent): Introduces on-demand loaded Skills, decoupling domain knowledge from the main prompt
The value of this path: each step only adds ONE “key mechanism,” so you clearly know “where capabilities come from” rather than swallowing a complex framework all at once.

### Learning Path Map

```
Start Here
    |
    v
[v0: Bash Agent] -----> "One tool is enough"
    |                    ~50 lines
    v
[v1: Model as Agent] -----> "Core loop"
    |                    ~200 lines
    v
[v2: Explicit Todo] -----> "Reduce going off-track"
    |                    ~300 lines
    v
[v3: Subagents] -------> "Task decomposition"
    |                    ~450 lines
    v
[v4: Skills] -------> "Knowledge externalization"
                         ~550 lines
```

### Version Comparison Table

| Version | Theme | Lines Added | Core Tools | Key Insight |
| --- | --- | --- | --- | --- |
| v0 | Bash is everything | ~50 | bash (1 tool) | One tool suffices, recursion = hierarchy |
| v1 | Model as Agent | ~200 | bash + read + write + edit | Model is decision-maker, code just runs the loop |
| v2 | Explicit Todo | ~300 | + TodoWrite | Explicit planning: less going off-track |
| v3 | Subagent mechanism | ~450 | + Task | Context isolation: exploration doesn’t pollute main session |
| v4 | Skills mechanism | ~550 | + Skill | Knowledge externalization: from training to editing |

### Chapter Quick Reference (Recommended Order)

| Chapter | Key Point to Grasp | Maps to Claude Code |
| --- | --- | --- |
| v0 | With just `bash` + tool loop, you can do “read/write/search/execute” | The “coding CLI” you see is essentially a tool loop |
| v1 | Separate tools clearly: Read/Write/Edit (closer to engineering implementation) | Why Claude Code’s file operations are more stable |
| v2 | TodoWrite + constraints (only 1 in_progress allowed) | Explicit planning: less going off-track, better collaboration |
| v3 | Subagents isolate context (exploration doesn’t pollute main session) | The value of Subagents (Explore/Plan, etc.) |
| v4 | Skills load on-demand, decoupling knowledge from main prompt | Skills make “norms/domain knowledge” reusable and maintainable |

## Start Learning
[v0: Bash is EverythingOne tool + loop, read/write/search/execute
](v0-bash-agent/)[v1: Model as AgentSeparate Read/Write/Edit for more stable behavior
](v1-model-as-agent/)[v2: Explicit TodoMake plans a visible state machine, reduce going off-track
](v2-explicit-planning-todo/)[v3: Subagent MechanismDivide and conquer, context isolation
](v3-subagents/)[v4: Skills MechanismKnowledge externalization: paradigm shift from training to editing
](v4-skills/)

## Hands-on Practice: Make Principles Work (Verifiable)
The following exercises don’t depend on a specific repository: you can implement a “minimal runnable” tool loop in any empty directory using your preferred language.

### Define Minimal Tools

Start with these two:

- read_file(path): Read a file and return its content
- bash(command): Execute read-only commands (e.g., ls, rg)
### Write a Minimal Loop (Pseudocode)

```python
messages = [{"role": "user", "content": "Find README in current directory and summarize key points"}]
tools = [read_file, bash]

while True:
    resp = model(messages, tools)
    if resp.stop_reason != "tool_use":
        print(resp.text)
        break
    results = execute_tools(resp.tool_calls)
    messages.append({"role": "user", "content": results})
```

### Verify the Loop Works with 3 Types of Questions

- Have it list the current directory and explain the structure (read/search)
- Have it create a file and write content (write)
- Have it run a simple command and explain the output (execute)
## Common Pitfalls & Troubleshooting

- Stuck on installation/running: First confirm Python version and dependencies are installed; then check if .env is taking effect (API Key exists).
- Cost and rate limits: Long exploration/repeated tool loops increase call counts; verify control flow with small tasks first, then extend to complex tasks.
## Further Reading (Related Links)

- Claude Code workflows: /docs/claude-code/workflows/
- Subagents: /docs/claude-code/advanced/subagents/
- Skills: /docs/claude-code/advanced/skills/
