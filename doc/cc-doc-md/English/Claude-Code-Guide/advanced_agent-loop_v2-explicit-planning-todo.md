# Claude-Code / Advanced / Agent-Loop / V2-Explicit-Planning-Todo

> 来源: claudecn.com

# v2: Explicit Todo

v1 works. But for complex tasks, the model loses direction.

Ask it to “refactor authentication, add tests, update docs” and watch what happens. Without explicit planning, it jumps between tasks, forgets steps, and loses focus.

v2 adds just one thing: the **Todo tool**. About 100 lines of new code that fundamentally changes how the agent works.

## The Problem

In v1, plans exist only in the model’s “head”:

```
v1: "I'll do A, then B, then C" (invisible)
    10 tool calls later: "Wait, what was I doing?"
```

The Todo tool makes it explicit:

```
v2:
  [ ] Refactor authentication module
  [>] Add unit tests         <- Currently here
  [ ] Update documentation
```

Now both you and the model can see the plan.

## TodoManager

A list with constraints:

```python
class TodoManager:
    def __init__(self):
        self.items = []  # Max 20 items

    def update(self, items):
        # Validation rules:
        # - Each item needs: content, status, activeForm
        # - Status: pending | in_progress | completed
        # - Only one in_progress allowed
        # - No duplicates, no empty items
```

The constraints matter:

| Rule | Reason |
| --- | --- |
| Max 20 items | Prevents infinite lists |
| Only one in_progress | Forces focus |
| Required fields | Structured output |

These aren’t arbitrary—they’re guardrails.

## Core Code Implementation

```python
#!/usr/bin/env python3
"""
v2_todo_agent.py - Mini Claude Code: Structured Planning (~300 lines)

Core Philosophy: "Make Plans Visible"
=====================================
v1 works great for simple tasks. But ask it to "refactor auth, add tests,
update docs" and watch what happens. Without explicit planning, the model:
  - Jumps between tasks randomly
  - Forgets completed steps
  - Loses focus mid-way

The Solution - TodoWrite Tool:
-----------------------------
v2 adds ONE new tool that fundamentally changes how the agent works:
"""

import os
import subprocess
import sys
from pathlib import Path

from anthropic import Anthropic
from dotenv import load_dotenv

load_dotenv(override=True)

# =============================================================================
# Configuration
# =============================================================================

WORKDIR = Path.cwd()
client = Anthropic(base_url=os.getenv("ANTHROPIC_BASE_URL"))
MODEL = os.getenv("MODEL_ID", "claude-sonnet-4-5-20250929")

# =============================================================================
# TodoManager - The core addition in v2
# =============================================================================

class TodoManager:
    """
    Manages a structured task list with enforced constraints.

    Key Design Decisions:
    --------------------
    1. Max 20 items: Prevents the model from creating endless lists
    2. One in_progress: Forces focus - can only work on ONE thing at a time
    3. Required fields: Each item needs content, status, and activeForm

    The activeForm field deserves explanation:
    - It's the PRESENT TENSE form of what's happening
    - Shown when status is "in_progress"
    - Example: content="Add tests", activeForm="Adding unit tests..."

    This gives real-time visibility into what the agent is doing.
    """

    def __init__(self):
        self.items = []

    def update(self, items: list) -> str:
        """
        Validate and update the todo list.

        Validation Rules:
        - Each item must have: content, status, activeForm
        - Status must be: pending | in_progress | completed
        - Only ONE item can be in_progress at a time
        - Maximum 20 items allowed

        Returns:
            Rendered text view of the todo list
        """
        validated = []
        in_progress_count = 0

        for i, item in enumerate(items):
            # Extract and validate fields
            content = str(item.get("content", "")).strip()
            status = str(item.get("status", "pending")).lower()
            active_form = str(item.get("activeForm", "")).strip()

            # Validation checks
            if not content:
                raise ValueError(f"Item {i}: content required")
            if status not in ("pending", "in_progress", "completed"):
                raise ValueError(f"Item {i}: invalid status '{status}'")
            if not active_form:
                raise ValueError(f"Item {i}: activeForm required")

            if status == "in_progress":
                in_progress_count += 1

            validated.append({
                "content": content,
                "status": status,
                "activeForm": active_form
            })

        # Enforce constraints
        if len(validated) > 20:
            raise ValueError("Max 20 todos allowed")
        if in_progress_count > 1:
            raise ValueError("Only one task can be in_progress at a time")

        self.items = validated
        return self.render()

    def render(self) -> str:
        """
        Render the todo list as human-readable text.

        Format:
            [x] Completed task
            [>] In progress task <- Doing something...
            [ ] Pending task

            (2/3 completed)
        """
        if not self.items:
            return "No todos."

        lines = []
        for item in self.items:
            if item["status"] == "completed":
                lines.append(f"[x] {item['content']}")
            elif item["status"] == "in_progress":
                lines.append(f"[>] {item['content']} <- {item['activeForm']}")
            else:
                lines.append(f"[ ] {item['content']}")

        completed = sum(1 for t in self.items if t["status"] == "completed")
        lines.append(f"\n({completed}/{len(self.items)} completed)")

        return "\n".join(lines)

# Global todo manager instance
TODO = TodoManager()

# =============================================================================
# System Prompt - Updated for v2
# =============================================================================

SYSTEM = f"""You are a coding agent at {WORKDIR}.

Loop: plan -> act with tools -> update todos -> report.

Rules:
- Use TodoWrite to track multi-step tasks
- Mark tasks in_progress before starting, completed when done
- Prefer tools over prose. Act, don't just explain.
- After finishing, summarize what changed."""

# =============================================================================
# System Reminders - Soft prompts to encourage todo usage
# =============================================================================

# Shown at the start of conversation
INITIAL_REMINDER = "<reminder>Use TodoWrite for multi-step tasks.</reminder>"

# Shown if model hasn't updated todos in a while
NAG_REMINDER = "<reminder>10+ turns without todo update. Please update todos.</reminder>"

# =============================================================================
# Tool Definitions (v1 tools + TodoWrite)
# =============================================================================

TOOLS = [
    # v1 tools (unchanged) - bash, read_file, write_file, edit_file
    # ... (same as v1)

    # NEW in v2: TodoWrite
    {
        "name": "TodoWrite",
        "description": "Update the task list. Use to plan and track progress.",
        "input_schema": {
            "type": "object",
            "properties": {
                "items": {
                    "type": "array",
                    "description": "Complete list of tasks (replaces existing)",
                    "items": {
                        "type": "object",
                        "properties": {
                            "content": {
                                "type": "string",
                                "description": "Task description"
                            },
                            "status": {
                                "type": "string",
                                "enum": ["pending", "in_progress", "completed"],
                                "description": "Task status"
                            },
                            "activeForm": {
                                "type": "string",
                                "description": "Present tense action, e.g. 'Reading files'"
                            },
                        },
                        "required": ["content", "status", "activeForm"],
                    },
                }
            },
            "required": ["items"],
        },
    },
]

# =============================================================================
# Agent Loop (with todo tracking)
# =============================================================================

# Track how many rounds since last todo update
rounds_without_todo = 0

def agent_loop(messages: list) -> list:
    """
    Agent loop with todo usage tracking.

    Same core loop as v1, but now we track whether the model
    is using todos. If it goes too long without updating,
    we inject a reminder into the next user message.
    """
    global rounds_without_todo

    while True:
        response = client.messages.create(
            model=MODEL,
            system=SYSTEM,
            messages=messages,
            tools=TOOLS,
            max_tokens=8000,
        )

        tool_calls = []
        for block in response.content:
            if hasattr(block, "text"):
                print(block.text)
            if block.type == "tool_use":
                tool_calls.append(block)

        if response.stop_reason != "tool_use":
            messages.append({"role": "assistant", "content": response.content})
            return messages

        results = []
        used_todo = False

        for tc in tool_calls:
            print(f"\n> {tc.name}")
            output = execute_tool(tc.name, tc.input)
            preview = output[:300] + "..." if len(output) > 300 else output
            print(f"  {preview}")

            results.append({
                "type": "tool_result",
                "tool_use_id": tc.id,
                "content": output,
            })

            # Track todo usage
            if tc.name == "TodoWrite":
                used_todo = True

        # Update counter: reset if used todo, increment otherwise
        if used_todo:
            rounds_without_todo = 0
        else:
            rounds_without_todo += 1

        messages.append({"role": "assistant", "content": response.content})

        # Inject NAG_REMINDER into user message if model hasn't used todos
        if rounds_without_todo > 10:
            results.insert(0, {"type": "text", "text": NAG_REMINDER})

        messages.append({"role": "user", "content": results})

def execute_tool(name: str, args: dict) -> str:
    """Dispatch tool call to implementation."""
    if name == "TodoWrite":
        return TODO.update(args["items"])
    # ... (other tools from v1)
    return f"Unknown tool: {name}"
```

## Tool Definition

```python
{
    "name": "TodoWrite",
    "input_schema": {
        "items": [{
            "content": "Task description",
            "status": "pending | in_progress | completed",
            "activeForm": "Present tense: 'Reading files'"
        }]
    }
}
```

`activeForm` shows what’s happening:

```
[>] Reading authentication code...  <- activeForm
[ ] Add unit tests
```

## System Reminders
Soft constraints that encourage todo usage:

```python
INITIAL_REMINDER = "<reminder>Use TodoWrite for multi-step tasks.</reminder>"
NAG_REMINDER = "<reminder>10+ turns without todo update. Please update.</reminder>"
```

Injected as context, not commands:

```python
if rounds_without_todo > 10:
    inject_reminder(NAG_REMINDER)
```

The model sees them but doesn’t respond to them.

## Feedback Loop

When the model calls `TodoWrite`:

```
Input:
  [x] Refactor authentication (completed)
  [>] Add tests (in progress)
  [ ] Update documentation (pending)

Returns:
  "[x] Refactor authentication
   [>] Add tests
   [ ] Update documentation
   (1/3 completed)"
```

The model sees its own plan, updates it, and continues with context.

## When to Use Todo

Not every task needs one:

| Suitable | Reason |
| --- | --- |
| Multi-step work | 5+ steps need tracking |
| Long conversations | 20+ tool calls |
| Complex refactoring | Multiple files |
| Teaching | Visible “thinking process” |

Rule of thumb: **If you would write a checklist, use todo.**

## Integration Approach

v2 adds to v1 without changing it:

```python
# v1 tools
tools = [bash, read_file, write_file, edit_file]

# v2 adds
tools.append(TodoWrite)
todo_manager = TodoManager()

# v2 tracks usage
if rounds_without_todo > 10:
    inject_reminder()
```

About 100 lines of new code. Agent loop unchanged.

## Deeper Insight

**Structure both constrains and enables.**

Todo’s constraints (max items, one in_progress) enable (visible plans, progress tracking).

Patterns in agent design:

- max_tokens constraint → enables manageable responses
- Tool schema constraint → enables structured calls
- Todo constraint → enables complex task completion
Good constraints aren’t limitations—they’re scaffolding.

---

**Explicit planning makes agents reliable.**
[v1: Model as AgentSeparate tools clearly: Read/Write/Edit
](../v1-model-as-agent/)[v3: Subagent MechanismDivide and conquer, context isolation
](../v3-subagents/)
