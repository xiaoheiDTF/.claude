# Agent-Skills

> 来源: claudecn.com

# Agent Skills

Agent Skills are modular capability systems that extend Claude’s functionality. Each Skill packages instructions, metadata, and optional resources (scripts, templates) that Claude uses automatically when relevant.

## Why Use Skills

Skills are reusable, filesystem-based resources that provide Claude with domain-specific expertise: workflows, context, and best practices, transforming a general agent into a specialist.

**Key Benefits**:

- Specialize Claude: Customize capabilities for specific domain tasks
- Reduce Repetition: Create once, use automatically
- Compose Capabilities: Combine Skills to build complex workflows
## Using Skills

Anthropic provides pre-built Agent Skills for common document tasks (PowerPoint, Excel, Word, PDF), and you can create your own custom Skills. Both work the same way—Claude uses them automatically when relevant.

### Pre-built Agent Skills

Available to all claude.ai and Claude API users. See the [Available Skills](#available-skills) section for the complete list.

### Custom Skills

Let you package domain expertise and organizational knowledge. Available across all Claude products: create in Claude Code, upload via API, or add in claude.ai settings.

## How Skills Work

Skills leverage Claude’s VM environment to provide capabilities beyond pure prompting. Claude runs in a virtual machine with filesystem access, allowing Skills to exist as directories containing instructions, executable code, and reference materials.

### Progressive Disclosure

Skills can contain three types of content, each loaded at different times:

**Level 1: Metadata (Always Loaded)**

- The Skill’s YAML frontmatter provides discovery information
- Claude loads this metadata at startup and includes it in the system prompt
- This lightweight approach means you can install many Skills without context penalty
**Level 2: Instructions (Loaded When Triggered)**

- The SKILL.md body contains procedural knowledge: workflows, best practices, and guidance
- When you request something matching the Skill description, Claude reads SKILL.md from the filesystem via bash
- Only then does the content enter the context window
**Level 3: Resources and Code (Loaded On-Demand)**

- Skills can bundle additional materials:Instructions: Additional markdown files
- Code: Executable scripts that Claude runs via bash
- Resources: Reference materials like database schemas, API docs, templates, or examples
| Level | Loading Time | Token Cost | Content |
| --- | --- | --- | --- |
| **Level 1: Metadata** | Always (at startup) | ~100 tokens/Skill | `name` and `description` in YAML frontmatter |
| **Level 2: Instructions** | When Skill triggers | **Required Fields**: `name` and `description`

**Frontmatter Limits**:

- name: Maximum 64 characters
- description: Maximum 1024 characters
## Quick Navigation
[QuickstartCreate your first Skill
](quickstart/)[Team Index TemplateWrite a real README or index page your team can actually use
](team-index-template/)[Best PracticesWrite Skills Claude can use effectively
](best-practices/)[API GuideUse Skills in Claude API
](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)

## Security Considerations

We strongly recommend using Skills only from trusted sources: ones you created yourself or obtained from Anthropic. Skills provide Claude with new capabilities through instructions and code—while this makes them powerful, it also means a malicious Skill could direct Claude to invoke tools or execute code in ways inconsistent with the Skill’s stated purpose.

## Limitations and Constraints

### Cross-Surface Availability

**Custom Skills do not sync across surfaces**. Skills uploaded to one surface are not automatically available on other surfaces.

### Runtime Environment Constraints

Skills run in code execution containers with the following limitations:

- No Network Access: Skills cannot make external API calls or access the internet
- No Runtime Package Installation: Only pre-installed packages are available
- Only Pre-configured Dependencies: See Code Execution Tool documentation for the list of available packages
## Next Steps
[QuickstartCreate your first Skill
](quickstart/)[Team Index TemplateTurn scattered Skills into a clear team entry point
](team-index-template/)[API GuideUse Skills in Claude API
](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)[Best PracticesWrite effective Skills
](best-practices/)

## Related Resources

- Official Documentation
- Anthropic Skills Repository
- Claude Cookbooks
