# Claude-Code / Advanced / Agent-Loop / V4-Skills

> 来源: claudecn.com

# v4: Skills Mechanism

## Knowledge Externalization: Paradigm Shift from Training to Editing

The Skills mechanism embodies a profound paradigm shift: **Knowledge Externalization**.

### Traditional Approach: Knowledge Internalized in Parameters

Traditional AI systems have all their knowledge locked in model parameters. You can’t access, modify, or reuse it.

Want to teach the model new skills? You need to:

- Collect large amounts of training data
- Set up distributed training clusters
- Perform complex parameter fine-tuning (LoRA, full fine-tuning, etc.)
- Deploy new model versions
It’s like the brain suddenly amnesiac, but you have no notes to recover memory. Knowledge is locked in the neural network’s weight matrices, completely opaque to users.

### New Paradigm: Knowledge Externalized to Documents

Code execution paradigm changes everything.

```
┌─────────────────────────────────────────────────────────────────┐
│                     Knowledge Storage Layer                      │
│                                                                  │
│  Model Parameters → Context Window → File System → Skill Library │
│       (Internal)          (Runtime)       (Persistent)      (Structured)   │
│                                                                  │
│  ←───────── Training Modifies ─────────→  ←──── Natural Language Modifies ──→  │
│     Requires cluster, data, expertise              Anyone can edit              │
└─────────────────────────────────────────────────────────────────┘
```

**Key breakthrough**:

- Past: Modify model behavior = modify parameters = need training = need GPU cluster + training data + expertise
- Present: Modify model behavior = modify SKILL.md = edit text file = anyone can do it
This is like adding a hot-pluggable LoRA weight to the base model, but you don’t need any parameter training on the model itself.

### Why This Matters

- Democratization: No longer need ML expertise to customize model behavior
- Transparency: Knowledge stored in human-readable Markdown, auditable and understandable
- Reusability: Write a Skill once, use on any compatible Agent
- Version control: Git manages knowledge changes, supports collaboration and rollback
- Online learning: Model “learns” in larger context windows without offline training
Traditional fine-tuning is **offline learning**: collect data → train → deploy → use.
Skills are **online learning**: load knowledge on-demand at runtime, immediate effect.

### Knowledge Layer Comparison

| Layer | Modification | 生效时间 | Persistence | Cost |
| --- | --- | --- | --- | --- |
| Model Parameters | Training/fine-tuning | Hours-days | Permanent | $10K-$1M+ |
| Context Window | API call | Instant | Within session | ~$0.01/call |
| File System | Edit file | Next load | Permanent | Free |
| **Skill Library** | **Edit SKILL.md** | **Next trigger** | **Permanent** | **Free** |

Skills are the sweet spot: persistent storage + on-demand loading + human-editable.

### Practical Significance

Say you want Claude to learn your company’s code standards:

**Traditional approach**:

```
1. Collect company codebase as training data
2. Prepare fine-tuning scripts and infrastructure
3. Run LoRA fine-tuning (requires GPU)
4. Deploy custom model
5. Cost: $1000+ and weeks of time
```

**Skills approach**:

```markdown
# skills/company-standards/SKILL.md
---
name: company-standards
description: Company code standards and best practices
---

## Naming Conventions
- Function names use lowercase_with_underscores
- Class names use PascalCase
...
```

```
Cost: $0, Time: 5 minutes
```

This is the power of knowledge externalization: **turn knowledge that requires training to encode into documents anyone can edit**.

## Problem Background

v3 gave us subagents to break down tasks. But there’s a deeper problem: **how does the model know how to handle domain-specific tasks?**

- Processing PDFs? Need to know whether to use pdftotext or PyMuPDF
- Building MCP servers? Need to know protocol specifications and best practices
- Code review? Need a systematic checklist
This knowledge isn’t tools—it’s **expertise**. Skills solve this by letting the model load domain knowledge on-demand.

## Core Concepts

### 1. Tools vs Skills

| Concept | What it is | Examples |
| --- | --- | --- |
| **Tool** | What the model **can do** | bash, read_file, write_file |
| **Skill** | What the model **knows how to do** | PDF processing, MCP building |

Tools are capabilities, skills are knowledge.

### 2. Progressive Disclosure

```
Layer 1: Metadata (always loaded)     ~100 tokens/skill
         └─ name + description

Layer 2: SKILL.md body (on trigger)   ~2000 tokens
         └─ Detailed guide

Layer 3: Resource files (on-demand)   Unlimited
         └─ scripts/, references/, assets/
```

This keeps context lightweight while allowing arbitrary depth of knowledge.

### 3. SKILL.md Standard

```
skills/
├── pdf/
│   └── SKILL.md          # Required
├── mcp-builder/
│   ├── SKILL.md
│   └── references/       # Optional
└── code-review/
    ├── SKILL.md
    └── scripts/          # Optional
```

**SKILL.md format**: YAML frontmatter + Markdown body

```markdown
---
name: pdf
description: Process PDF files. Use for reading, creating, or merging PDFs.
---

# PDF Processing Skills

## Reading PDFs

Use pdftotext for quick extraction:
\`\`\`bash
pdftotext input.pdf -
\`\`\`
...
```

## Core Code Implementation

```python
#!/usr/bin/env python3
"""
v4_skills_agent.py - Mini Claude Code: Skills Mechanism (~550 lines)

Core Philosophy: "Knowledge Externalization"
============================================
v3 gave us subagents for task decomposition. But there's a deeper question:

    How does the model know HOW to handle domain-specific tasks?

The Paradigm Shift: Knowledge Externalization
--------------------------------------------
Traditional AI: Knowledge locked in model parameters
  - To teach new skills: collect data -> train -> deploy
  - Cost: $10K-$1M+, Timeline: Weeks

Skills: Knowledge stored in editable files
  - To teach new skills: write a SKILL.md file
  - Cost: Free, Timeline: Minutes
"""

import os
import re
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
SKILLS_DIR = WORKDIR / "skills"
client = Anthropic(base_url=os.getenv("ANTHROPIC_BASE_URL"))
MODEL = os.getenv("MODEL_ID", "claude-sonnet-4-5-20250929")

# =============================================================================
# SkillLoader - The core addition in v4
# =============================================================================

class SkillLoader:
    """
    Manages loading and parsing of skill files.

    Key Design Decisions:
    --------------------
    1. Progressive disclosure: Metadata always loaded, body on demand
    2. Standard format: YAML frontmatter + Markdown body
    3. File-based: Git-friendly, human-readable, editable
    """

    def __init__(self, skills_dir: Path):
        self.skills_dir = skills_dir
        self.skills = {}
        self.load_skills()

    def load_skills(self):
        """Discover and load all skill metadata."""
        if not self.skills_dir.exists():
            return

        for skill_path in self.skills_dir.glob("*/SKILL.md"):
            skill = self.parse_skill_md(skill_path)
            if skill:
                self.skills[skill["name"]] = skill

    def parse_skill_md(self, path: Path) -> dict:
        """
        Parse YAML frontmatter + Markdown body.

        Returns:
            {name, description, body, path, dir}
        """
        content = path.read_text()

        # Match YAML frontmatter
        match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)

## Message Injection (Preserving Cache)
Key insight: Skill content enters as **tool_result** (part of user message), not system prompt:

```python
def run_skill(skill_name: str) -> str:
    content = SKILLS.get_skill_content(skill_name)
    # Full content returned as tool_result
    # Becomes part of conversation history (user message)
    return f"""<skill-loaded name="{skill_name}">
{content}
</skill-loaded>

Follow the instructions in the skill above."""

def agent_loop(messages: list) -> list:
    while True:
        response = client.messages.create(
            model=MODEL,
            system=SYSTEM,  # Never changes - cache stays valid!
            messages=messages,
            tools=ALL_TOOLS,
        )
        # Skill content enters messages as tool_result...
```

**Key insight**:

- Skill content is appended as a new message at the end
- All previous content (system prompt + history) is cache-reused
- Only the newly appended skill content needs computation, the entire prefix hits cache
## Comparison with Production

| Mechanism | Claude Code / Kode | v4 |
| --- | --- | --- |
| Format | SKILL.md (YAML + MD) | Same |
| Loading | Container API | SkillLoader class |
| Trigger | Auto + Skill tool | Skill tool only |
| Injection | newMessages (user message) | tool_result (user message) |
| Cache mechanism | Append at end, prefix all cached | Append at end, prefix all cached |
| Version control | Skill Versions API | Omitted |
| Permissions | allowed-tools field | Omitted |

**Key commonality**: Both inject skill content into conversation history (not system prompt), keeping prompt cache valid.

## Why This Matters: Caching and Cost

### Autoregressive Models and KV Cache

Large models are autoregressive: generating each token requires attending to all previous tokens. To avoid recomputation, providers implement **KV Cache**:

```
Request 1: [System, User1, Asst1, User2]
        ←────── All computed ──────→

Request 2: [System, User1, Asst1, User2, Asst2, User3]
        ←────── Cache hit ──────→ ←─ New compute ─→
               (cheaper)            (normal price)
```

Cache hit requires **identical prefix**.

### Patterns to Watch

| Operation | Impact | Result |
| --- | --- | --- |
| Edit history | Changes prefix | Cache cannot be reused |
| Insert in middle | Subsequent prefix changes | Need recompute |
| Modify system prompt | Front changes | Entire prefix needs recompute |

### Recommendation: Append Only

```python
# Avoid: Edit history
messages[2]["content"] = "edited"  # Cache invalid

# Recommend: Append only
messages.append(new_msg)  # Prefix unchanged, cache hit
```

### Long Context Support
Mainstream models support large context windows:

- Claude Sonnet 4.5 / Opus 4.5: 200K
- GPT-5.2: 256K+
- Gemini 3 Flash/Pro: 1M
200K tokens ≈ 150K words, a 500-page book. For most Agent tasks, current context windows are sufficient.

**Treat context as an append-only log, not an editable document.**

## Series Summary

| Version | Theme | Lines Added | Core Insight |
| --- | --- | --- | --- |
| v1 | Model as Agent | ~200 | Model is 80%, code is just the loop |
| v2 | Structured planning | ~100 | Todo makes plans visible |
| v3 | Divide and conquer | ~150 | Subagents isolate context |
| **v4** | **Domain expert** | **~100** | **Skills inject professional knowledge** |

---

**Tools let the model do things, skills let the model know how.**
[v3: Subagent MechanismDivide and conquer, context isolation
](../v3-subagents/)[Agent Skills DocumentationDeep dive into Claude Code’s Skills system
](../../skills/)

, content, re.DOTALL)
        if not match:
            return None

        frontmatter_text, body = match.groups()

        # Parse YAML frontmatter
        frontmatter = {}
        for line in frontmatter_text.strip().split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                frontmatter[key.strip()] = value.strip()

        return {
            "name": frontmatter.get("name", path.parent.name),
            "description": frontmatter.get("description", ""),
            "body": body.strip(),
            "path": path,
            "dir": path.parent
        }

    def get_descriptions(self) -> str:
        """
        Generate metadata list for system prompt.

        This is always loaded (Layer 1: ~100 tokens/skill).
        """
        if not self.skills:
            return "No skills available."

        return "\n".join(
            f"- {name}: {skill['description']}"
            for name, skill in self.skills.items()
        )

    def get_skill_content(self, name: str) -> str:
        """
        Get full skill content for context injection.

        This is loaded on demand (Layer 2: ~2000 tokens).
        """
        if name not in self.skills:
            return f"Skill '{name}' not found."

        skill = self.skills[name]
        return f"# Skill: {name}\n\n{skill['body']}"

# Global skill loader instance
SKILLS = SkillLoader(SKILLS_DIR)

# =============================================================================
# System Prompt - Updated for v4
# =============================================================================

SYSTEM = f"""You are a coding agent at {WORKDIR}.

Loop: plan -> act with tools -> update todos -> report.

Rules:
- Use TodoWrite to track multi-step tasks
- Use Skill tool to load domain expertise when needed
- Prefer tools over prose. Act, don't just explain.
- After finishing, summarize what changed.

Available Skills:
{SKILLS.get_descriptions()}"""

# =============================================================================
# Skill Tool - Loads domain knowledge on demand
# =============================================================================

TOOLS = [
    # v1-v3 tools (unchanged)
    # ... bash, read_file, write_file, edit_file, TodoWrite, Task

    # NEW in v4: Skill tool
    {
        "name": "Skill",
        "description": "Load a skill to get domain expertise.",
        "input_schema": {
            "type": "object",
            "properties": {
                "skill": {
                    "type": "string",
                    "description": "Name of the skill to load"
                }
            },
            "required": ["skill"],
        },
    },
]

# =============================================================================
# Tool Execution with Skill Support
# =============================================================================

def run_skill(skill_name: str) -> str:
    """
    Load and inject skill content into conversation.

    Key insight: Skill content enters as tool_result (user message),
    not system prompt. This preserves cache!
    """
    content = SKILLS.get_skill_content(skill_name)

    # Return as tool result - becomes part of conversation history
    return f"""<skill-loaded name="{skill_name}">
{content}
</skill-loaded>

Follow the instructions in the skill above."""

def execute_tool(name: str, args: dict) -> str:
    """Dispatch tool call to implementation."""
    if name == "Skill":
        return run_skill(args["skill"])
    # ... (other tools from v1-v3)
    return f"Unknown tool: {name}"
```

## Message Injection (Preserving Cache)
Key insight: Skill content enters as **tool_result** (part of user message), not system prompt:

%%CODE_BLOCK_8%%

**Key insight**:

- Skill content is appended as a new message at the end
- All previous content (system prompt + history) is cache-reused
- Only the newly appended skill content needs computation, the entire prefix hits cache
## Comparison with Production

| Mechanism | Claude Code / Kode | v4 |
| --- | --- | --- |
| Format | SKILL.md (YAML + MD) | Same |
| Loading | Container API | SkillLoader class |
| Trigger | Auto + Skill tool | Skill tool only |
| Injection | newMessages (user message) | tool_result (user message) |
| Cache mechanism | Append at end, prefix all cached | Append at end, prefix all cached |
| Version control | Skill Versions API | Omitted |
| Permissions | allowed-tools field | Omitted |

**Key commonality**: Both inject skill content into conversation history (not system prompt), keeping prompt cache valid.

## Why This Matters: Caching and Cost

### Autoregressive Models and KV Cache

Large models are autoregressive: generating each token requires attending to all previous tokens. To avoid recomputation, providers implement **KV Cache**:

%%CODE_BLOCK_9%%

Cache hit requires **identical prefix**.

### Patterns to Watch

| Operation | Impact | Result |
| --- | --- | --- |
| Edit history | Changes prefix | Cache cannot be reused |
| Insert in middle | Subsequent prefix changes | Need recompute |
| Modify system prompt | Front changes | Entire prefix needs recompute |

### Recommendation: Append Only

%%CODE_BLOCK_10%%

### Long Context Support
Mainstream models support large context windows:

- Claude Sonnet 4.5 / Opus 4.5: 200K
- GPT-5.2: 256K+
- Gemini 3 Flash/Pro: 1M
200K tokens ≈ 150K words, a 500-page book. For most Agent tasks, current context windows are sufficient.

**Treat context as an append-only log, not an editable document.**

## Series Summary

| Version | Theme | Lines Added | Core Insight |
| --- | --- | --- | --- |
| v1 | Model as Agent | ~200 | Model is 80%, code is just the loop |
| v2 | Structured planning | ~100 | Todo makes plans visible |
| v3 | Divide and conquer | ~150 | Subagents isolate context |
| **v4** | **Domain expert** | **~100** | **Skills inject professional knowledge** |

---

**Tools let the model do things, skills let the model know how.**
[v3: Subagent MechanismDivide and conquer, context isolation
](../v3-subagents/)[Agent Skills DocumentationDeep dive into Claude Code’s Skills system
](../../skills/)
