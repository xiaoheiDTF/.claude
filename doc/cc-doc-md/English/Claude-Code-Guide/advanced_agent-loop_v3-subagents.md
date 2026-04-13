# Claude-Code / Advanced / Agent-Loop / V3-Subagents

> 来源: claudecn.com

# v3: Subagent Mechanism

v2 added planning. But for large tasks like “explore codebase then refactor authentication”, a single agent hits context limits. The exploration process dumps 20 files into history, and the refactor loses focus.

v3 adds the **Task tool**: spawns subagents with isolated contexts.

## The Problem

Single agent context pollution:

```
Main Agent History:
  [Exploring...] cat file1.py -> 500 lines
  [Exploring...] cat file2.py -> 300 lines
  ... 15 files ...
  [Now refactoring...] "Wait, what was in file1 again?"
```

Solution: **Delegate exploration to subagent**:

```
Main Agent History:
  [Task: Explore codebase]
    -> Subagent explores 20 files
    -> Returns: "Auth is in src/auth/, database is in src/models/"
  [Now refactor with clean context]
```

## Agent Type Registry
Each agent type defines its capabilities:

```python
AGENT_TYPES = {
    "explore": {
        "description": "Read-only, for searching and analyzing",
        "tools": ["bash", "read_file"],  # Cannot write
        "prompt": "Search and analyze. Do not modify. Return concise summary."
    },
    "code": {
        "description": "Full agent, for implementation",
        "tools": "*",  # All tools
        "prompt": "Implement changes efficiently."
    },
    "plan": {
        "description": "Planning and analysis",
        "tools": ["bash", "read_file"],  # Read-only
        "prompt": "Analyze and output numbered plan. Do not modify files."
    }
}
```

## Core Code Implementation

```python
#!/usr/bin/env python3
"""
v3_subagent.py - Mini Claude Code: Subagents (~450 lines)

Core Philosophy: "Divide and Conquer with Context Isolation"
===========================================================
v2 added planning. But for large tasks like "explore codebase then refactor auth",
a single agent hits context limits. Exploration dumps 20 files into history,
then refactor loses focus.

v3 adds the Task tool: spawns subagents with isolated contexts.
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
# Agent Type Registry - The core addition in v3
# =============================================================================

AGENT_TYPES = {
    "explore": {
        "description": "Read-only, for searching and analyzing",
        "tools": ["bash", "read_file"],  # No write tools
        "prompt": "Search and analyze. Do not modify. Return concise summary."
    },
    "code": {
        "description": "Full agent, for implementation",
        "tools": "*",  # All tools
        "prompt": "Implement changes efficiently."
    },
    "plan": {
        "description": "Planning and analysis",
        "tools": ["bash", "read_file"],  # Read-only
        "prompt": "Analyze and output numbered plan. Do not modify files."
    }
}

def get_tools_for_agent(agent_type: str) -> list:
    """
    Filter tools based on agent type.

    - explore: Only bash + read_file
    - code: All tools
    - plan: Only bash + read_file

    Subagents don't get Task tool (prevents infinite recursion).
    """
    allowed = AGENT_TYPES[agent_type]["tools"]
    if allowed == "*":
        # Return all tools except Task (no recursion in demo)
        return [t for t in TOOLS if t["name"] != "Task"]
    return [t for t in TOOLS if t["name"] in allowed]

# =============================================================================
# Task Tool - Spawns subagents
# =============================================================================

TOOLS = [
    # v1 tools (unchanged)
    # ... bash, read_file, write_file, edit_file

    # v2 TodoWrite (unchanged)
    # ... TodoWrite

    # NEW in v3: Task tool
    {
        "name": "Task",
        "description": "Spawn a subagent for focused subtasks.",
        "input_schema": {
            "type": "object",
            "properties": {
                "description": {
                    "type": "string",
                    "description": "Short task name (3-5 words)"
                },
                "prompt": {
                    "type": "string",
                    "description": "Detailed instructions for the subagent"
                },
                "agent_type": {
                    "type": "string",
                    "enum": ["explore", "code", "plan"],
                    "description": "Type of subagent to spawn"
                }
            },
            "required": ["description", "prompt", "agent_type"],
        },
    },
]

# =============================================================================
# Subagent Execution
# =============================================================================

def run_subagent(description: str, prompt: str, agent_type: str) -> str:
    """
    Execute a subagent with isolated context.

    Key concepts:
    1. Context isolation: Fresh sub_messages = []
    2. Tool filtering: get_tools_for_agent()
    3. Specialized behavior: Agent-specific system prompt
    4. Result abstraction: Only return final text
    """
    config = AGENT_TYPES[agent_type]

    # 1. Agent-specific system prompt
    sub_system = f"""You are a {agent_type} subagent working in {WORKDIR}.

{config['prompt']}

Rules:
- Prefer tools over prose. Act, don't just explain.
- Return a concise summary of your findings."""

    # 2. Filtered tools
    sub_tools = get_tools_for_agent(agent_type)

    # 3. Isolated history (KEY: no parent context)
    sub_messages = [{"role": "user", "content": prompt}]

    # 4. Same agent loop
    tool_count = 0
    while True:
        response = client.messages.create(
            model=MODEL,
            system=sub_system,
            messages=sub_messages,
            tools=sub_tools,
            max_tokens=8000,
        )

        # Collect tool calls
        tool_calls = []
        for block in response.content:
            if block.type == "tool_use":
                tool_calls.append(block)

        # If no tool calls, we're done
        if response.stop_reason != "tool_use":
            # Return final text only
            return "".join(b.text for b in response.content if hasattr(b, "text"))

        # Execute tools
        results = []
        for tc in tool_calls:
            tool_count += 1
            output = execute_tool(tc.name, tc.input)
            results.append({
                "type": "tool_result",
                "tool_use_id": tc.id,
                "content": output[:50000],  # Truncate long outputs
            })

        sub_messages.append({"role": "assistant", "content": response.content})
        sub_messages.append({"role": "user", "content": results})

def execute_tool(name: str, args: dict) -> str:
    """Dispatch tool call to implementation."""
    if name == "Task":
        return run_subagent(args["description"], args["prompt"], args["agent_type"])
    # ... (other tools from v1/v2)
    return f"Unknown tool: {name}"
```

## Task Tool

```python
{
    "name": "Task",
    "description": "Spawn a subagent for focused subtasks",
    "input_schema": {
        "description": "Short task name (3-5 words)",
        "prompt": "Detailed instructions",
        "agent_type": "explore | code | plan"
    }
}
```

Main agent calls Task → subagent runs → returns summary.

## Subagent Execution

The core of the Task tool:

```python
def run_task(description, prompt, agent_type):
    config = AGENT_TYPES[agent_type]

    # 1. Agent-specific system prompt
    sub_system = f"You are a {agent_type} subagent.\n{config['prompt']}"

    # 2. Filtered tools
    sub_tools = get_tools_for_agent(agent_type)

    # 3. Isolated history (KEY: no parent context)
    sub_messages = [{"role": "user", "content": prompt}]

    # 4. Same loop
    while True:
        response = client.messages.create(
            model=MODEL, system=sub_system,
            messages=sub_messages, tools=sub_tools
        )
        if response.stop_reason != "tool_use":
            break
        # Execute tools, append results...

    # 5. Return final text only
    return extract_final_text(response)
```

**Key concepts:**

| Concept | Implementation |
| --- | --- |
| Context isolation | Fresh `sub_messages = []` |
| Tool filtering | `get_tools_for_agent()` |
| Specialized behavior | Agent-specific system prompt |
| Result abstraction | Return final text only |

## Tool Filtering

```python
def get_tools_for_agent(agent_type):
    allowed = AGENT_TYPES[agent_type]["tools"]
    if allowed == "*":
        return BASE_TOOLS  # No Task (no recursion in demo)
    return [t for t in BASE_TOOLS if t["name"] in allowed]
```

- explore: Only bash + read_file
- code: All tools
- plan: Only bash + read_fileSubagents don’t get Task tool (prevents infinite recursion).

## Progress Display

Subagent output doesn’t pollute main chat:

```
You: Explore codebase
> Task: Explore codebase
  [explore] Explore codebase ... 5 tools, 3.2s
  [explore] Explore codebase - Complete (8 tools, 5.1s)

Here's what I found: ...
```

Real-time progress, clean final output.

## Typical Workflow

```
User: "Refactor authentication to use JWT"

Main Agent:
  1. Task(explore): "Find all auth-related files"
     -> Subagent reads 10 files
     -> Returns: "Auth is in src/auth/login.py, sessions are in..."

  2. Task(plan): "Design JWT migration plan"
     -> Subagent analyzes structure
     -> Returns: "1. Add jwt library 2. Create token utility..."

  3. Task(code): "Implement JWT tokens"
     -> Subagent writes code
     -> Returns: "Created jwt_utils.py, updated login.py"

  4. Summarize changes
```

Each subagent has clean context. Main agent stays focused.

## Comparison

| Aspect | v2 | v3 |
| --- | --- | --- |
| Context | Single, growing | Isolated per task |
| Exploration | Pollutes history | Contained in subagent |
| Parallel | No | Possible (not in demo) |
| New code | ~300 lines | ~450 lines |

## Pattern

```
Complex task
  └─ Main Agent (coordinator)
       ├─ Subagent A (explore) -> Summary
       ├─ Subagent B (plan) -> Plan
       └─ Subagent C (code) -> Result
```

Same agent loop, different contexts. That’s the entire trick.

---

**Divide and conquer. Context isolation.**
[v2: Explicit TodoMake plans a visible state machine, reduce going off-track
](../v2-explicit-planning-todo/)[v4: Skills MechanismKnowledge externalization: paradigm shift from training to editing
](../v4-skills/)
