# Source-Analysis / Governance

> 来源: claudecn.com

# Execution Governance

Claude Code’s permission system is not a simple allow/deny switch — it is a distributed runtime boundary spanning four layers: mode, rules, hooks, and sandboxing. Understanding this governance chain matters more than understanding any single tool, because it determines whether the system can operate as a credible execution platform rather than a raw tool caller.

Visual counterpart: [Runtime page](https://code.claudecn.com/runtime/)

## Why governance deserves its own page

If you only read `src/tools/`, it is easy to conclude that Claude Code is powerful because it has many tools.

The more important truth is that tools are only the action surface. The system becomes operationally credible because action attempts are filtered through permission modes, rule evaluation, hooks, and sandboxing.

## Four layers of governance

```
Allow → Ask → Deny → Allow → Deny → Tool call request → Mode layer → PermissionMode → Rule layer → allow / deny / ask → Decision layer → toolPermission Hook → Execution layer → Sandbox constraints → User confirmation → Reject execution → Actual execution
```

| Layer | Purpose | Representative evidence |
| --- | --- | --- |
| Mode layer | Defines the session posture: default, plan, acceptEdits, bypassPermissions | `src/types/permissions.ts`, `src/utils/permissions/PermissionMode.ts` |
| Rule layer | Merges allow, deny, ask, and additional directory scopes into runtime state | `src/utils/permissions/permissions.ts`, `src/utils/permissions/permissionSetup.ts` |
| Decision layer | Applies interactive, coordinator, or worker-side permission handling before execution | `src/hooks/toolPermission/` |
| Execution layer | Applies final shell, filesystem, and sandbox boundaries | `src/utils/sandbox/sandbox-adapter.ts`, `src/utils/permissions/filesystem.ts` |

These four layers are not a linear “frontend prompt → backend execution” pipeline. They form a runtime boundary system that can re-enter multiple times within a single request.

## How an action is governed

- The session enters the main loop with a permission mode and a rule set.
- Before a tool executes, src/hooks/toolPermission/ evaluates the current toolPermissionContext to decide: allow, deny, or ask.
- If a decision must be surfaced, the runtime emits hook events such as PermissionRequest and PermissionDenied — not just a temporary UI prompt.
- Even when a higher-level mode allows execution, sandbox and filesystem restrictions can still narrow the final behavior.
That is why `acceptEdits` or `bypassPermissions` should not be read as “no structure left”. Session posture and execution boundary are related, but they are not identical.

## Governance also exists in configuration space

The settings surface shows both `permissions.*` and `sandbox.*`. That separation matters:

- permissions.* determines who may attempt an action
- sandbox.* determines what the execution environment still permits after that attempt is allowed
Claude Code treats those as complementary layers, not substitutes.

## Cross-channel governance

Bridge-side tool calls also carry `permission_mode` and `allowed_domains`. This means governance is treated as a cross-channel protocol, not a local implementation detail — the boundary model survives beyond local shell tools and into extension or bridge surfaces.

## Lessons for agent builders

| Pattern | Description |
| --- | --- |
| **Restrict first, relax later** | Default to the strictest mode; let users explicitly opt into relaxation — don’t start wide open and patch later |
| **Permissions beyond prompts** | Rule matching, hook interception, and sandbox constraints stack independently — any layer can block on its own |
| **Governance crosses channels** | The permission model travels with `tool_call` payloads into Bridge and MCP — it is not limited to local tools |
| **Configuration vs. runtime** | `permissions.*` controls “who may attempt”; `sandbox.*` controls “what’s still allowed even after permission is granted” |

## Path evidence

| Path | Responsibility |
| --- | --- |
| `src/types/permissions.ts` | Type-level permission mode and exposure boundary definitions |
| `src/utils/permissions/PermissionMode.ts` | Mode-to-user-visible semantics mapping |
| `src/utils/permissions/permissions.ts` | Rule parsing into runtime-decidable structures |
| `src/utils/permissions/permissionSetup.ts` | Session context wiring into the governance system |
| `src/hooks/toolPermission/` | Pre-execution permission decision and interaction |
| `src/utils/sandbox/sandbox-adapter.ts` | Final execution environment constraints |
| `src/utils/settings/permissionValidation.ts` | Configuration-side governance validation |

## Further reading

- Runtime Loop — where permission gates sit in the seven stages
- Memory System — governance and continuity intersection
- Tool Plane — the full tool landscape under governance
- Signals & Extensions — how governance extends to the extension surface
