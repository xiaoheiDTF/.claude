# Agent-Skills / Architecture

> 来源: claudecn.com

# Skills Architecture Design

This article explores the technical architecture and design philosophy of Agent Skills, helping you understand how Skills efficiently extend Claude’s capabilities.

## Core Design Philosophy

Agent Skills adopt a **Progressive Disclosure** architecture, a “lazy loading” mechanism from modern [ software engineering](#) that ensures Claude only loads necessary content when needed, avoiding context window waste.

### Design Goals

- Efficiency first: Minimize token consumption
- Load on demand: Only load detailed content for relevant Skills
- Modular: Skills are independent of each other, composable
- Scalable: Support unlimited number of Skills without affecting performance
## Three-Tier Progressive Loading Architecture

Skills content is divided into three levels, each loaded at different times:

```
+-------------------------+
|   Level 1: Metadata     |  ← Loaded at Claude startup: 100 tokens/skill
+-------------------------+
|   Level 2: Instructions |  ← Loaded on request match: <5k tokens
+-------------------------+
|   Level 3: Resources    |  ← Loaded on execution as needed: virtually unlimited
+-------------------------+
```

### Level 1: Metadata
**Load timing**: At Claude startup, always loaded

**Content**:

- Skill name
- Brief description
- Optional tags and categories
**Cost**: ~100 tokens per Skill

**Purpose**:

- Help Claude discover available Skills
- Quickly determine relevance to user requests
- Lightweight design allows installing many Skills
**Example**:

```yaml
---
name: "PPT Generator"
description: "Creates PowerPoint presentations based on user descriptions. Use when users ask to create slides or presentations."
tags: ["document", "presentation", "office"]
---
```

### Level 2: Instructions
**Load timing**: When Claude determines Skill is relevant to request

**Content**:

- Detailed usage guidelines
- Workflow steps
- Best practice recommendations
- Input/output examples
**Cost**: <5k tokens (recommended to keep concise)

**Purpose**:

- Tell Claude how to correctly use this Skill
- Provide context and domain knowledge
- Guide Claude’s behavior and decisions
**Example**:

```markdown
## Usage Guide

### Workflow
1. Analyze user's presentation topic and target audience
2. Determine number and structure of slides
3. Generate title and bullet points for each slide
4. Use appropriate layouts and visual elements
5. Generate final PPTX file

### Best Practices
- Keep each slide content concise
- Use consistent visual style
- Provide charts for complex concepts

### Example
Input: "Create a 5-page presentation about AI ethics"
Output: Professional presentation with introduction, three main points, and conclusion
```

### Level 3: Resources
**Load timing**: When executing specific tasks, loaded as needed

**Content**:

- Executable scripts: Python, Bash, etc.
- Template files: PPTX templates, document templates, etc.
- Reference docs: API documentation, database schemas, etc.
- Sample data: Test data, configuration files, etc.
**Cost**: Virtually unlimited (file content doesn’t directly enter context)

**Access method**:

- Claude reads files via bash commands: cat REFERENCE.md
- Execute scripts: python scripts/generate_ppt.py
- Only command output enters context window
**Directory structure example**:

```
my-skill/
├── SKILL.md              # Level 1+2: Metadata and instructions
├── REFERENCE.md          # Level 3: API reference
├── FORMS.md             # Level 3: Form template documentation
├── scripts/
│   ├── generate.py      # Level 3: Generation script
│   └── validate.py      # Level 3: Validation script
└── templates/
    ├── basic.pptx       # Level 3: Presentation template
    └── professional.pptx # Level 3: Professional template
```

## Virtual Machine Environment
Skills run in Claude’s code execution container, which provides:

### File System Access

- Skills can read and write files
- Supports standard file operations
- Files persist during session
### Code Execution Capability

- Run Python, Bash, and other scripts
- Use pre-installed packages and libraries
- Execute deterministic computational tasks
### Security Restrictions

For security, the code execution environment has these limitations:

- No network access: Cannot make external API calls
- No runtime package installation: Only pre-installed packages available
- Resource limits: CPU and memory usage restricted
See [Code Execution Tool Documentation](https://docs.claude.com/en/docs/agents-and-tools/tool-use/code-execution-tool) for available package list.

## Context Engineering Perspective

From a context engineering perspective, Skills architecture embodies several important principles:

### 1. Clear Boundaries

Skills form a complete context lifecycle through SKILL, FORMS, REFERENCE, scripts, and VM environment:

- Definition: SKILL.md defines capabilities and usage
- Transfer: Transfer knowledge through file system
- Execution: Execute specific tasks in VM
### 2. Minimize Context Pollution

- Metadata always loaded, but cost is low
- Instructions only loaded when needed
- Resources accessed through file system, don’t occupy context
### 3. Balance Determinism and Flexibility

- Deterministic tasks: Use scripts to ensure consistent output
- Creative tasks: Use natural language guidance to allow flexibility
## Multi-Skill Collaboration

Claude can use multiple Skills simultaneously to complete complex tasks:

### Automatic Orchestration

Claude will, based on task requirements:

- Identify relevant Skills
- Determine usage order
- Coordinate input/output between Skills
### Example Workflow

**Task**: “Analyze sales data and create quarterly report presentation”

**Skill orchestration**:

- Excel Skill: Read and analyze sales data
- Excel Skill: Generate charts and statistics
- PowerPoint Skill: Create presentation framework
- PowerPoint Skill: Insert charts and key findings
### Composition Advantages

- Each Skill focuses on specific tasks
- Skills share data through files
- Claude handles overall coordination and decisions
## Comparison with MCP

| Feature | Agent Skills | MCP |
| --- | --- | --- |
| **Context Cost** | Very low (progressive loading) | High (full loading) |
| **Loading Method** | Load instructions and resources on demand | Load complete definition at startup |
| **Design Philosophy** | Context engineering | Prompt engineering |
| **Execution Environment** | VM + file system | External API calls |
| **Reliability** | Executable code ensures determinism | Depends on API responses |
| **Portability** | Cross Claude platforms (API, Code, Web) | Requires MCP server configuration |

## Performance Optimization Strategies

### Metadata Optimization

- Keep name and description concise and clear
- Use verb phrases to describe functions
- Include trigger condition hints
### Instruction Optimization

- Keep SKILL.md within 500 lines
- Use checklists rather than long descriptions
- Provide clear input/output examples
- Assume Claude knows basic concepts
### Resource Optimization

- Place detailed documentation in separate REFERENCE.md
- Use scripts to handle complex logic
- Keep template files reasonably sized
- Avoid deep directory nesting
## Architecture Evolution

Skills architecture design deeply draws from:

- Manus context engineering practices
- Modern  software engineering lazy loading patterns
- Microservice architecture modular thinking
This design represents evolution from “prompt engineering” to “context engineering,” providing a more scientific paradigm for AI capability extension.

## Next Steps
[Quick StartCreate your first Skill
](../quickstart/)[Best PracticesWrite efficient Skills
](../best-practices/)[Claude CodeUse Skills in Claude Code
](https://claudecn.com/en/docs/claude-code/)

## Reference Resources

- Official Docs: Skills Overview
- Skills GitHub Repository
- Code Execution Tool Documentation
