# Source-Analysis / Plugins

> 来源: claudecn.com

# Plugin System

From skill files to distributable extension packages — Plugins are the top-level container in Claude Code’s extension architecture, solving not “how to define a capability” but “how to discover, trust, install, update, and uninstall a set of capabilities.”

## Core Question

Skills let you define a reusable prompt template in Markdown. But when you want to package a set of Skills, several Hooks, a pair of MCP servers, and a custom command suite into a distributable product, you need Plugins.

Plugins answer harder questions: **How do a thousand users use the same plugin without interfering? How do you verify safety before installation? How do you upgrade without breaking existing config?**

## Subsystem Overview

| Metric | Value |
| --- | --- |
| **Core service files** | 3 main files + Schema definitions |
| **Directory** | `src/services/plugins/`, `src/utils/plugins/` |
| **Maturity** | Integrated (merged into trunk) |
| **Manifest Schema** | ~1,700 lines of Zod definitions |

## Plugin Manifest Architecture

Everything starts with the `plugin.json` manifest. Its validation Schema is the largest single Schema definition in Claude Code (`schemas.ts` ~1,681 lines), composed of 11 sub-schemas:

| Sub-Schema | Description |
| --- | --- |
| **Metadata** | Name, version, author, keywords, dependencies (required) |
| **Hooks** | Hook definitions (`hooks.json` or inline) |
| **Commands** | Custom commands (`commands/*.md`) |
| **Agents** | Custom agent definitions |
| **Skills** | Skill files (`skills/**/SKILL.md`) |
| **Output Styles** | Output style customization |
| **Channels** | MCP message injection |
| **MCP Servers** | MCP server configuration |
| **LSP Servers** | LSP server configuration |
| **Settings** | Preset values |
| **User Config** | Installation-time user prompts |

All sub-schemas except Metadata use `.partial()` — a hooks-only plugin and a full-toolchain plugin share the same format.

```
plugin.json → PluginManifest → Metadata → name, version, author → Hooks → Lifecycle interception → Commands → Custom commands → Agents → Agent definitions → Skills → SKILL.md files → MCP Servers → Tool services → LSP Servers → Language services → Settings → Preset configs
```

## Lifecycle Management

| File | Responsibility |
| --- | --- |
| `PluginInstallationManager.ts` | Install, uninstall, version management |
| `pluginCliCommands.ts` | CLI entry points (`install` / `uninstall` / `list`) |
| `pluginOperations.ts` | Runtime loading and operations |

### Installation Sources

Plugins can be installed from multiple sources: local directories, Git repositories, npm packages, marketplace, etc. The installation process includes a validation chain:

- Manifest validation: Full Zod Schema verification
- Path safety: All file paths must start with ./, cannot contain ..
- Name protection: Cannot impersonate official marketplace names (anthropic-marketplace etc. are reserved)
- Version isolation: Different versions use independent cache directories
### Error Handling

Plugin loading uses 25 discriminated union error types. This is not simple `try/catch` — each failure mode has structured error information for diagnosis and recovery.

## Plugins vs Skills

| Dimension | Skills | Plugins |
| --- | --- | --- |
| **Granularity** | Single prompt template | Capability bundle container |
| **Distribution** | Project-level `.claude/skills/` | Cross-project installable package |
| **Lifecycle** | Discovery → Invocation | Install → Load → Run → Update → Uninstall |
| **Trust boundary** | Project-level trust | Requires signature and source verification |
| **Composability** | Single skill | Skills + commands + hooks + MCP + LSP |
| **Definition format** | SKILL.md (YAML + Markdown) | plugin.json (Zod Schema validated) |

## Key Design Decisions

### Progressive Composition

Plugins don’t require implementing all 11 component types. The `.partial()` design lets the simplest plugin need only a `metadata` plus a `hooks` config, while the most complex can provide a complete toolchain.

### Marketplace Name Reservation

```
ALLOWED_OFFICIAL_MARKETPLACE_NAMES:
  claude-code-marketplace, claude-code-plugins,
  claude-plugins-official, anthropic-marketplace,
  anthropic-plugins, agent-skills, ...
```

Reserved name mechanism + `inline`/`builtin` special name protection prevents third-party plugins from impersonating official sources.

### Versioned Cache Isolation

Different plugin versions use independent cache directories, avoiding state contamination during upgrades. This is especially important for stateful MCP servers and LSP servers.

## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Containerized extensions** | Don’t make users manually assemble skills + hooks + config — provide a unified installation entry |
| **Schema as documentation** | 1,700 lines of Zod Schema is itself the most precise plugin format documentation |
| **Fail closed** | 25 error types mean every failure has an explicit handling path, not a generic `Error` |
| **Name governance** | Ecosystems need name protection from day one |
| **Progressive complexity** | Keep simple use cases simple (one hook), make complex use cases possible (full toolchain) |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/services/plugins/` | Plugin service directory |
| `src/services/plugins/PluginInstallationManager.ts` | Installation manager |
| `src/services/plugins/pluginCliCommands.ts` | CLI entry points |
| `src/services/plugins/pluginOperations.ts` | Runtime operations |
| `src/utils/plugins/schemas.ts` | Manifest Schema definitions (~1,681 lines) |
| `src/utils/plugins/` | Plugin utility functions |

## Further Reading

- Tool Plane — How plugin-registered tools enter the tool system
- Execution Governance — Plugin trust boundaries
- Signals & Extensions — Plugins’ position in the extension fabric
- Memory System — Plugin-memory interaction
