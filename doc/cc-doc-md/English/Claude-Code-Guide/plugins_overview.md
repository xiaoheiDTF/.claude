# Claude-Code / Plugins / Overview

> 来源: claudecn.com

# Understand plugins first

The value of a plugin is not that it wraps a prompt in a new file. The value is that it packages a stable capability into something installable and repeatable. A plugin can carry commands, Agents, Skills, Hooks, MCP configuration, and the tool wiring that makes them useful in real work.

## Start with the right mental model

It helps to think of a plugin as a capability package. The important part is not a single file. The important part is turning a way of working into something reusable, shareable, and updatable.

Common plugin surfaces include:

- slash commands
- Agents
- Skills
- Hooks
- MCP configuration
- local tooling or language-service integration
## When a plugin is the right choice

### You want reuse across projects

If the same workflow keeps showing up across multiple projects, a plugin is usually better than copying config over and over.

### You want a team to share one working method

When a team needs shared commands, review steps, quality gates, or tool wiring, a plugin is more reliable than informal conventions.

### You need versioned maintenance

If the capability will evolve over time, installation, updates, and configuration are much easier to manage through a plugin.

## When not to rush into a plugin

### It is still a one-project experiment

If you are only testing an idea, local project config is usually enough.

### The process is not stable yet

Plugins work best once the workflow has settled down. Before that, getting the task flow right matters more than packaging it early.

## A typical plugin lifecycle

- Define the job the plugin should improve
- Choose an existing, team, or local plugin source
- Install it and test it on a small task
- Decide whether it belongs in daily work
- Add versioning and configuration once the workflow proves useful
## What to verify right after installation

```bash
/plugin list
```

Then check four things:

- the commands you need actually appear
- the expected Agents or Skills can be triggered
- required MCP services or local tools are available
- the plugin makes a common task faster or safer instead of adding overhead
## When building your own plugin makes more sense

If your need is clearly team-specific, such as review checklists, commit flow, internal tools, or organization-specific rules, building a plugin is often better than stretching a general-purpose one.

The best framing is simple:

“After installation, which class of work becomes more reliable or faster for our team?”

The clearer that answer is, the easier it is to design a useful plugin.

## Next steps

- Want to try one first: read Discover and install plugins
- Need to decide where to start: read Choose plugin sources
- Ready to package your own workflow: read Create Plugins
