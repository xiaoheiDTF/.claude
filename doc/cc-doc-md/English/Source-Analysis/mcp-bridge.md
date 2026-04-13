# Source-Analysis / Mcp-Bridge

> 来源: claudecn.com

# MCP & Bridge

MCP integration and Bridge cross-interface connectivity form the two core channels of Claude Code’s extension fabric — one reaching outward to external tool capabilities, one connecting inward to multi-surface interfaces.

## Core Question

How does an agent system gain external capabilities without modifying core code? How does the same agent simultaneously support CLI, IDE, Desktop, and Mobile? MCP and Bridge answer these two questions respectively.

## MCP Integration

### Transport Layer

Claude Code supports 6 MCP transport methods:

| Transport | Description |
| --- | --- |
| **stdio** | Standard I/O, local process communication |
| **SSE** | Server-Sent Events, HTTP long polling |
| **HTTP** | Standard HTTP request/response |
| **WebSocket** | Full-duplex communication |
| **SDK** | Anthropic SDK native integration |
| **claude.ai proxy** | Relay through claude.ai |

### Configuration Scopes

MCP servers can be registered across 7 configuration scopes:

| Scope | Coverage | Typical Use |
| --- | --- | --- |
| Global user config | All projects | Universal tools (search, browser) |
| Project `.mcp.json` | Single project | Project-specific tools |
| CLAUDE.md declaration | Project/local | Lightweight tool declarations |
| Plugin-embedded | Plugin scope | MCP servers bundled with plugins |
| Environment variables | Session-level | Temporary overrides |
| SDK mode | Programmatic use | SDK client-provided |
| IDE config | IDE scope | VS Code / JetBrains integration |

### Tool Naming and Registration

MCP tools follow the `mcp__<server>__<tool>` naming pattern, dynamically registered into the tool system. This means MCP tools share with built-in tools:

- The same permission check flow
- The same execution orchestration (parallel/serial partitioning)
- The same result budget mechanism
- The same hook interception points
This “unified tool surface” design prevents external tools from bypassing the governance system.

### OAuth 2.0 + PKCE

Remote MCP server authentication uses OAuth 2.0 + PKCE, supporting:

- Authorization code flow (for environments with a browser)
- Device code flow (for pure CLI environments)
- Token caching and refresh
## Bridge Cross-Interface Connectivity

### Multi-Surface Architecture

Bridge is not an experimental feature but an integrated cross-interface connection capability. It lets the same Claude Code instance be accessed through multiple interfaces:

| Surface | Command Entry | Purpose |
| --- | --- | --- |
| **IDE** | `src/commands/ide` | VS Code, JetBrains editors |
| **Desktop** | `src/commands/desktop` | Electron desktop application |
| **Mobile** | `src/commands/mobile` | Mobile control |
| **Chrome** | `src/commands/chrome` | Browser extension |

### Mailbox Mechanism

Bridge implements cross-interface messaging through Mailbox:

- src/utils/mailbox.ts — Message mailbox core
- src/context/mailbox.tsx — Mailbox UI context
The message mailbox is asynchronous — senders don’t need receivers to be online. This lets the CLI run in the background while IDE interfaces connect/disconnect at will.

```
Interface Channel → MCP Channel → Claude Code Core → Agent Loop → Bridge Service → src/bridge/ → Mailbox → Message Queue → stdio MCP Server → HTTP MCP Server → claude.ai Proxy → CLI Terminal → VS Code / JetBrains → Desktop App → Mobile
```

## Where the Two Channels Meet

MCP and Bridge play different but complementary roles in the extension fabric:

| Dimension | MCP | Bridge |
| --- | --- | --- |
| **Direction** | Outward: connecting external capabilities | Inward: connecting multi-surface interfaces |
| **Registration timing** | At config time or runtime discovery | At process startup |
| **Communication pattern** | Request/response | Message mailbox (async) |
| **Governance** | Unified tool surface | Independent connection management |

The two channels intersect in some scenarios: an IDE can connect to Claude Code via Bridge, while Claude Code connects back to the IDE’s LSP service via MCP.

## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Unified tool surface** | External tools (MCP) and built-in tools share the same governance — no backdoors |
| **Multi-transport adaptation** | Don’t assume users have only one network environment — support from stdio to WebSocket |
| **Async mailbox** | Cross-interface communication shouldn’t require both parties online — message queues are more robust |
| **Layered configuration** | Global → project → plugin → session, letting users override at the appropriate scope |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/services/mcp/` | MCP integration core |
| `src/bridge/` | Bridge service core |
| `src/utils/mailbox.ts` | Message mailbox mechanism |
| `src/context/mailbox.tsx` | Mailbox UI context |
| `src/commands/bridge` | Bridge command entry |
| `src/commands/ide` | IDE integration commands |

## Further Reading

- Architecture Map — Extension fabric in the six-layer structure
- Tool Plane — MCP tool registration and governance
- Plugin System — How plugins embed MCP servers
- Signals & Extensions — Bridge maturity assessment
