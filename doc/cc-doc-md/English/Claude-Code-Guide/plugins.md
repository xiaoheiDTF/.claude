# Claude-Code / Plugins

> 来源: claudecn.com

# Plugins

Plugins are the right tool when you want a capability to be installable, shareable, and versioned. Whether you want to use an existing extension or package your team’s workflow into one, this section stays focused on three practical questions: when to use a plugin, where to install it from, and how to tell if it actually improves your work.

## Start here
[Understand plugins firstLearn when plugins help and when project-local config is enough
](overview/)[Choose plugins by jobPick official plugins by review, feature work, LSP, design, or MCP-building needs
](by-use/)[Discover and install pluginsChoose an install source and learn how to validate what you installed
](discover-plugins/)[Choose plugin sourcesDecide when to start with the official directory and when to build team or local plugins
](official-marketplace/)[Create PluginsPackage team rules, commands, and capabilities into your own plugin
](create-plugins/)[Plugins ReferenceUse this when you need commands, config details, or technical behavior
](plugins-reference/)

## When plugins are worth considering

- you want commands, Agents, Skills, or MCP config to work across projects
- you want teammates to share the same workflow after installation
- you want capability updates to be versioned instead of scattered across chats and temporary files
## When you may not need a plugin yet

- you are only testing an idea inside one project
- you only need a few local commands or prompts
- the workflow is still changing too quickly to package well
In those cases, project-local `.claude/` config is usually faster and lighter.

## Recommended reading order

If this is your first time working with plugins, follow this order:

- Start with Understand plugins first
- Then run through Discover and install plugins
- If you are unsure which kinds of plugins to try first, read Choose plugins by job
- If you are making a sourcing decision, read Choose plugin sources
- Only after that move into Create Plugins
## Plugins vs project-local config

| Approach | Best for |
| --- | --- |
| Project-local config | one project, fast experiments, personal habits |
| Plugins | cross-project reuse, team sharing, long-term maintenance |

## Shortest useful path

```bash
/plugin marketplace list
/plugin install code-simplifier@claude-plugins-official
/plugin list
```

The goal is not to install many plugins. The goal is to install one small capability that clearly improves a task you already do often.
