# Agent-Skills / Team-Index-Template

> 来源: claudecn.com

# Team Index Template

Many teams do not fail because they cannot write a Skill. They fail because once the number of Skills grows, there is no human-friendly index page.

The result is predictable:

- new teammates do not know what exists
- experienced teammates only remember the few Skills they use all the time
- the same task gets different Skill combinations from different people
- Skills exist, but team adoption stays low
The fix is straightforward: write a real index page for `.claude/skills/README.md` or whatever shared Skills directory your team uses.

The goal is not to restate the Skill spec. The goal is to help the team answer three questions quickly:

- what Skills do we have?
- what is each one for?
- which ones should I combine for this task?
If you have not created your first Skill yet, start with [Quickstart](quickstart/). If you want stronger Skill bodies first, read [Best Practices](best-practices/).

## What a team index page should solve

A useful team index page needs to serve two groups at once:

- people entering the project for the first time
- people already using Skills who need to choose the right combination quickly
That means the page should usually include:

- category lists
- one-line purposes for each Skill
- recommended bundles for common tasks
- a small maintenance rule set
## Minimum template

This template is enough for most teams to get started:

```markdown
# Team Skills Index

This directory contains the long-lived Skills maintained for this project or team.

## Working rules

- choose by task type first
- for one task, start with 1 to 3 core Skills, not everything at once
- if something looks outdated, fix the index first, then the Skill body

## Skills by Category

### Development and Quality

| Skill | Purpose | When to use |
|---|---|---|
| `testing-patterns` | Standardize test style and TDD flow | new tests, regressions, flaky test fixes |
| `code-review-checklist` | Shared review checklist | pre-commit checks, PR review |
| `systematic-debugging` | Structured debugging flow | build failures, production issue tracing |

### Frontend and UI

| Skill | Purpose | When to use |
|---|---|---|
| `frontend-design` | Shared frontend implementation direction | new pages, components, visual refresh |
| `core-components` | Reuse the design system correctly | development inside an existing component library |

## Recommended bundles

### Building a new feature
1. `backend-patterns`
2. `testing-patterns`
3. `code-review-checklist`

### Fixing a production issue
1. `systematic-debugging`
2. `testing-patterns`

### Building a new page
1. `frontend-design`
2. `core-components`
3. `testing-patterns`

## Maintenance rules

- every new Skill must update this index
- every Skill gets one short purpose line, not a long essay
- review stale entries and stale bundles once a month
```

## Four things teams often miss

### 1. Do not turn the index into another full document
An index page is not where you rewrite every Skill in detail. Its job is selection, not deep explanation.

For each Skill, the page usually only needs:

- the name
- one sentence of purpose
- one sentence about when to use it
### 2. Recommended bundles matter more than a flat list

Many teams list Skills but never list bundles. That creates a familiar problem:

- people know what exists
- but they still do not know what to start with for a real task
Bundles are often the highest-value part of the page because real work rarely maps to one Skill only.

### 3. Group by task, not by implementation

It is usually better to group by real work such as:

- development and quality
- frontend and UI
- data and API
- documentation and communication
- platform and operations
People care more about what they are trying to do than about what implementation bucket a Skill belongs to.

### 4. The index must be maintained with the change

A common failure mode is simple:

- the Skill gets added
- the index does not
Two months later, the index is no longer trustworthy.

The most practical rule is:

- new Skill means index update
- renamed or deprecated Skill means index update
- bundles should be reviewed on a cadence
## A stronger team pattern

Once your Skill set gets larger, a two-layer entry often works better:

### Layer 1: quick task entry

- build a feature
- fix a bug
- review code
- build a page
- write documentation
- process data
### Layer 2: full category index

- list all Skills
- keep each one to a one-line description
This gives new teammates a task-first path while still preserving a complete directory.

## When the page should evolve further

If you are seeing any of these, the page is ready for a stronger structure:

- you have more than 10 to 15 Skills
- teammates keep asking which Skill applies to which task
- the same task is handled very differently by different people
- you want to connect bundles to commands, agents, or plugins
At that point you can add:

- a task-to-Skill mapping table
- required or strongly recommended bundles
- links to related commands, agents, and hooks
## Where to put it

Two common locations work well:

- .claude/skills/README.md
- a project document such as skills-index.md
If the page should serve both Claude and human teammates, `.claude/skills/README.md` is usually the best first choice.

## Next steps

- To create your first Skill, start with Quickstart
- To improve Skill quality, continue with Best Practices
- To see official examples, read Examples
