# Claude-Code / Plugins / Official-Marketplace

> 来源: claudecn.com

# Choose plugin sources

When people first approach plugins, the harder question is rarely “what command do I run?” The harder question is “where should I start?” For most teams, the answer is simpler than it looks: begin with the official directory, then decide whether it is already enough. If not, move into team plugins or local plugins.

## Why many teams start with the official directory

The main advantage is not that it solves everything. The main advantage is that it is easy to start with:

- the install path is clear
- common capabilities are easier to find
- it works well for validating a workflow before you invest in packaging your own
If your current goal is to improve coding, review, commit flow, design checks, language tooling, or common integrations, starting from the official directory is usually the lowest-cost move.

If you already know you want to begin with the official directory but do not know which kinds of plugins to try first, go directly to [Choose plugins by job](by-use/).

## What you will usually find there

The most common capability bands look like this:

- development workflow helpers
- language-service and local tooling integrations
- external service integrations
- output-style and working-mode helpers
That makes the official directory a strong first layer: improve common work first, then decide whether your team needs something more specific.

## When the official directory is already enough

It is often enough when your need is one of these:

- common coding workflows
- common platform integrations
- general review, commit, debugging, or output enhancements
## When team plugins are the better next step

Move toward team plugins when the workflow is clearly organization-specific, for example:

- internal coding standards
- fixed review checklists
- internal platform entry points
- private MCP services
- commands tightly coupled to company process
These cases are usually better served by a team plugin than by stretching a general-purpose one.

## When local plugins are the faster choice

If you are still testing an idea, iterating quickly, or adding a temporary capability to one project, local plugins are often the fastest option. They work well for short-cycle experiments before you decide whether something deserves wider sharing.

## Four things to check before installing

- who maintains it
- what permissions, services, or binaries it depends on
- whether it solves one of your highest-frequency problems
- whether the team can realistically maintain it over time
## A simple decision line

- Ask whether the need is general-purpose or team-specific
- For general-purpose needs, start with claude-plugins-official
- For team-specific needs, prefer a team plugin source
- For experimentation, start local
## Shortest useful path

```bash
/plugin marketplace list
/plugin install code-simplifier@claude-plugins-official
/plugin list
```

If your next step is installation and validation, continue with [Discover and install plugins](discover-plugins/). If you already know existing options are not enough, continue with [Create Plugins](create-plugins/).
