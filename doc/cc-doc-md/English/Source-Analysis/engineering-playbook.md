# Source-Analysis / Engineering-Playbook

> 来源: claudecn.com

# Engineering Playbook

## Why this page exists

Understanding the source structure is not the same as turning those capabilities into a maintainable team workflow.

In practice, teams usually get stuck on questions like:

- Should we start with commands, skills, hooks, plugins, or MCP?
- Which capabilities should stay narrow first, and which can be automated later?
- How do we turn “we can use one feature” into “we can run one stable workflow”?
- How do we avoid ending up with too many folders, too many rules, and no real ownership?
This page compresses the source-analysis findings into a route that is closer to actual engineering execution.

## Stage 1: Build a capability inventory before building a platform

Do not start by “building the whole framework.” Start by identifying which layer of capability you actually need.

Use these five layers as your smallest inventory:

| Layer | Best for | Read first |
| --- | --- | --- |
| **Command entry** | Give users a stable action surface | [Command Surface](https://claudecn.com/en/docs/source-analysis/commands/) |
| **Tool capability** | Let the model operate files, shell, and external systems safely | [Tool Plane](https://claudecn.com/en/docs/source-analysis/tools/) |
| **Execution boundary** | Control when writes, approvals, and external access are allowed | [Execution Governance](https://claudecn.com/en/docs/source-analysis/governance/) |
| **Extension container** | Package skills, commands, hooks, and MCP together | [Plugin System](https://claudecn.com/en/docs/source-analysis/plugins/) |
| **Long-session continuity** | Keep context, memory, recovery, and rollback connected | [Memory System](https://claudecn.com/en/docs/source-analysis/memory/) |

### Deliverables for this stage

- your own capability inventory table
- clear separation between project-level, user-level, and runtime-only capabilities
- only one or two shortest paths selected for the first rollout
## Stage 2: Narrow the execution boundary before adding automation

One of the most common mistakes is pushing automation before the boundary model exists.

A safer order is:

- define what stays read-only
- define what requires approval
- decide what can run automatically
- only then connect hooks, MCP, plugins, and multi-agent flows
The important lesson here is not a specific config. It is Claude Code’s boundary model:

- plan is not just a prompt pattern, it is permission narrowing
- sandboxing is not optional polish, it is the last boundary
- hooks are not convenience scripts, they are decision points in the execution chain
- automation is only worth enabling once fallback paths are clear
### Checklist for this stage

- Have you established the factual boundary from Research Method?
- Can you clearly separate read-only, write, and external-access actions?
- Is there a path back to a safe state on failure?
- Can you answer who approves, where approval happens, and how recovery works?
## Stage 3: Combine capabilities into one minimal workflow

Features do not become workflows by themselves. Before wider rollout, you need one minimal closed loop.

A usable minimal loop usually looks like this:

- user starts from a stable entry
- system enters analysis or planning
- tools execute under clear boundaries
- result is independently verified
- rollback or recovery remains available
Three combinations matter most:

| Combination | Typical use | Related topics |
| --- | --- | --- |
| **commands + tools + governance** | repeatable daily actions, lower-risk automation | [Command Surface](https://claudecn.com/en/docs/source-analysis/commands/) + [Tool Plane](https://claudecn.com/en/docs/source-analysis/tools/) + [Execution Governance](https://claudecn.com/en/docs/source-analysis/governance/) |
| **memory + compaction + session recovery** | long tasks, multi-turn execution | [Memory System](https://claudecn.com/en/docs/source-analysis/memory/) + [Runtime Loop](https://claudecn.com/en/docs/source-analysis/runtime/) |
| **multi-agent + independent verification** | decomposition, parallel research, independent checks | [Coordinator Mode](https://claudecn.com/en/docs/source-analysis/coordinator/) |

### Deliverables for this stage

- one minimal workflow from input to verification
- one explicit verification step instead of self-approval by the implementer
- one demo-sized example the team can actually use
## Stage 4: Turn the workflow into a shared team asset

Only after the smallest workflow works should you move into sharing and distribution.

Now the real questions become:

- Is this a project asset or a personal asset?
- Should it be a command template, a skill, or a plugin?
- Should config, resources, and scripts live in the repo or in user scope?
The most transferable lesson from Claude Code here is: **do not make users manually assemble too many moving parts.**

If a workflow depends on commands, hooks, MCP, skills, and settings together, it should likely become a clearer distribution unit instead of a copy-paste checklist.

### Recommendations for this stage

- single actions should stay commands or skills first
- grouped capabilities can move into a plugin-style container
- team-shared content and local personal content must be layered separately
- every entry point needs a README or index so installation does not become tribal knowledge
## Stage 5: Add operational safeguards last

What makes the system maintainable over time is not feature count. It is runtime safety.

At minimum, fill these five safeguard areas:

- recovery: can the system continue, retry, or roll back?
- session continuity: can a long task resume after interruption?
- cost visibility: are tokens, time, and model shifts observable?
- state externalization: do key plans and memory live outside the transcript?
- verification independence: is there a dedicated acceptance path beyond the implementer?
Recommended reading:

- Runtime Loop
- Memory System
- Cost Tracking
- Hooks & Resilience
## Common mistakes

### Mistake 1: Building the full framework first

Many teams create many folders, templates, and rules before even proving one minimal path. Complexity arrives first; reliability never does.

### Mistake 2: Treating planning as “just one extra confirmation”

Planning matters because it separates exploration, approval, and execution into a governable state machine.

### Mistake 3: No independent verification

If implementation and verification share the same context, the system will overestimate its own correctness. This is one of the most valuable lessons in [Coordinator Mode](https://claudecn.com/en/docs/source-analysis/coordinator/).

### Mistake 4: Treating plugins as “large skills”

Plugins solve discovery, installation, validation, updating, and removal. They are not just “a few files bundled together.”

## Recommended order

If you want to bring Claude Code patterns into your own team workflow, this is the safer sequence:

- read Research Method
- build a capability inventory
- establish the execution boundary
- prove one minimal workflow
- then add team distribution and operational safeguards
That is far more maintainable than copying someone else’s directory structure.
