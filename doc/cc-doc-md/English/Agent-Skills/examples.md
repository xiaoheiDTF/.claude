# Agent-Skills / Examples

> 来源: claudecn.com

# Skills Examples

This page introduces open-source examples from Anthropic’s official Skills repository across domains like document workflows, creative design, and engineering. The current synced snapshot contains 17 top-level Skills directories, and they are useful references when creating your own Skills.

## Skills repo structure

Anthropic’s Skills repository uses a standardized structure:

```
anthropics/skills/
├── skills/           # All Skills
│   ├── doc-coauthoring/
│   ├── docx/
│   ├── frontend-design/
│   └── ...
├── spec/             # Agent Skills spec
│   └── agent-skills-spec.md
└── template/         # Skill template
    └── SKILL.md
```

**Repository**: [https://github.com/anthropics/skills](https://github.com/anthropics/skills)

## Document workflow Skills

### doc-coauthoring — collaborative document drafting

**Added** (2025-01): a structured co-authoring workflow.

**Key features**:

- three-phase flow: context gathering → refinement/structure → reader testing
- supports multiple doc types (specs, decision docs, proposals, RFCs)
- integrates team tools (Slack/Teams/Google Drive)
- can generate image alt-text
**Workflow outline**:

- Context gathering: collect background, ask clarifying questions, consolidate discussion
- Refinement & structure: iterate on sections, brainstorm and edit, shape the outline
- Reader testing: test with a fresh Claude instance to find blind spots and ensure standalone readability
**Trigger examples**:

```
"write a doc", "draft a proposal", "create a spec"
"PRD", "design doc", "decision doc", "RFC"
```

### docx — Word document processing
**Key features**:

- create and edit DOCX files
- supports OOXML (ISO/IEC 29500-4)
- styles, tables, images
- comments/review flows
Typical layout:

```
skills/docx/
├── SKILL.md
├── docx-js.md
└── ...
```

## Creative & design Skills (how to learn from them)
When studying creative/design Skills (e.g., a frontend design workflow), focus on:

- what the Skill’s “definition of done” is
- how it limits scope and asks for missing inputs
- what templates and checklists it bundles
## Engineering Skills (how to learn from them)

When studying engineering-focused Skills, look for:

- how they separate “always-loaded metadata” vs “on-demand instructions/resources”
- how they use scripts to make execution deterministic
- how they define safe tool usage boundaries
## Skill modular design: what to copy into your own Skills

Practical patterns to borrow:

- explicit triggers and “when to use”
- a fixed workflow with phases and outputs
- a checklist for quality and safety
- optional scripts/templates for repeatable results
## How to use these examples

### Modify SKILL.md

Start by copying a close example and editing:

- the YAML front matter (name, description, etc.)
- triggers and workflow steps
- checklists and templates
- references and scripts
## Related resources

- Agent Skills
- Anthropic skills repo: https://github.com/anthropics/skills
## Contributing

If you want to contribute examples or improvements, follow the contribution guidelines in Anthropic’s Skills repository.

## License

The Anthropic Skills repository is open source. See the repo’s license for details.

## Summary

The fastest way to build high-quality Skills is to start from proven examples: copy structure, keep workflows explicit, and use scripts/resources to reduce ambiguity.
