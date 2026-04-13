# Claude-Code / Plugins / Discover-Plugins

> 来源: claudecn.com

# Discover and install plugins

Before installing anything, first decide what problem you are solving. For most users, only three decisions really matter: where to install from, how to validate what you installed, and when to switch to another source.

## The three most common install sources

### 1. Start from the official directory

If you need common development workflows, common integrations, or generally useful capability upgrades, the official directory is the easiest place to begin:

```bash
/plugin marketplace list
/plugin install code-simplifier@claude-plugins-official
```

This is the best path when you want to try one useful capability quickly.

### 2. Install from a team or private source

If the capability is clearly organization-specific, such as internal commands, private MCP services, or team review rules, a team plugin source usually fits better:

```bash
/plugin marketplace add example-team/plugins
/plugin install plugin-name@example-team-plugins
```

### 3. Install directly from local or source code
If you are experimenting, debugging, or actively building your own plugin, install directly from a local path or source:

```bash
/plugin install ./my-plugin
```

or:

```bash
/plugin install owner/repo
```

## How to decide which source to use

- want to try a mature general-purpose capability: start from the official directory
- want to package team rules and internal systems: use a team or private source
- want to iterate quickly while building: install locally or from source
## Do not stop at “install succeeded”
List installed plugins first:

```bash
/plugin list
```

Then validate with a small real task:

- do the commands you need actually exist?
- are required tools or services available?
- does the plugin make the task easier in practice?
If a plugin only adds another concept layer without improving real work, it probably does not belong in your everyday setup yet.

## Common management commands

### Update marketplace indexes

```bash
/plugin marketplace update claude-plugins-official
```

### Upgrade a plugin

```bash
/plugin upgrade <plugin-name>
```

### Uninstall a plugin

```bash
/plugin uninstall <plugin-name>
```

## Common questions

### What if /plugin is not available?
Check that your Claude Code version supports plugins, then update to a recent supported release.

### What if installation succeeds but nothing shows up?

Check three things first:

- the plugin is actually enabled
- required local tools or services are present
- your task is triggering the expected capability
### What if my setup feels heavier after installing many plugins?

That usually means the plugin set is too broad. Go back to real work and keep only the plugins that clearly improve speed, consistency, or quality.

## Next steps

- Want the core mental model first: read Understand plugins first
- Want to decide when to start from the official directory: read Choose plugin sources
- Want to package your own capability: read Create Plugins
