# Source-Analysis / Research-Method

> 来源: claudecn.com

# Research Method

## Why this page exists

If you only read the official docs, you learn what Claude Code can do and how Anthropic recommends using it. If you only read a source snapshot, you see paths, types, and runtime details, but you can easily lose reading order.

This page exists to answer three practical questions:

- What should you read first to build the right mental model fastest?
- What should be treated as a hard factual boundary, and what should only be treated as a structural signal?
- What is actually worth carrying from public examples and community practice into your own team?
## How this differs from official materials

Official materials are better for questions like:

- What is this feature?
- What are the supported boundaries?
- What is the smallest runnable example?
- What is the recommended integration path right now?
Source analysis is better for questions like:

- How do those capabilities converge inside one system?
- Why are permissions, compaction, memory, and recovery placed inside the main loop?
- Which design choices are stable skeleton, and which are only local signals?
- If you are building your own agent harness, which patterns are worth migrating?
In short: **official docs define capability boundaries; source analysis explains system structure.**

## Four working methods we extracted

### 1. Confirm capability primitives first, then study composition

Recent official quickstarts, skills, and plugin materials share the same pattern: define a primitive, make the smallest runnable entry work, then expand.

That means your reading order should not start from directories. A better sequence is:

- Runtime Loop and Tool Plane
- Command Surface and Plugin System
- Coordinator Mode and MCP & Bridge
This way, you read how capabilities are organized, not just how files are arranged.

### 2. Do not copy directory shape; reorganize by task

The most valuable lesson from public learning materials is not their folder layout. It is that they usually emphasize:

- readers need a path
- capabilities should be understood by task and stage
- different phases require different learning depth
That is why this site reorganizes the snapshot into overview, structural layer, runtime layer, capability layer, and evolution layer. The directory tree is evidence, not the final content structure.

### 3. Replace examples while keeping verification points

Minimal examples matter, but the thing that makes them production-useful is not “can it run once.” It is “does each replacement still leave a verification point.”

When reading the source, pay special attention to whether:

- permission decisions can fall back safely
- compaction can resume the main loop cleanly
- verification stays independent in multi-agent orchestration
- plugins, skills, and MCP are exposed on demand instead of all at once
This is why the analysis repeatedly focuses on runtime invariants rather than module lists.

### 4. Planning before execution is a system boundary

One clear trend in recent materials is that mature agent systems increasingly value explore first, plan first, execute later.

That is not just an interaction preference. It is an engineering boundary:

- confirm direction before write access expands
- persist the plan as an explicit artifact
- give recovery, rollback, and collaboration a stable anchor
So when reading Claude Code, Plan Mode should not be treated as just another feature. It is closer to a state machine for human alignment, permission narrowing, and task persistence.

## Three recommended reading modes

### If you are a daily user

Start with:

- Runtime Loop
- Execution Governance
- Cost Tracking
Your goal is to understand why the system denies, compacts, or recovers, not to memorize a feature list.

### If you are an agent builder

Start with:

- Architecture Map
- Runtime Loop
- Memory System
- Coordinator Mode
Your goal is to extract a runtime skeleton, governance boundary, and verification model for your own system.

### If you are a source researcher

Start with:

- Source Analysis Overview
- Tool Plane
- Command Surface
- Signals & Extensions
Your goal is to distinguish direct evidence, semantic grouping, and interpretive judgment, without reading snapshot signals as product promises.

## The most valuable thing to migrate is not the directory, but the principle

What we actually absorbed from the latest materials is not someone else’s layout or wording, but these more stable engineering principles:

- start with the smallest capability primitive
- organize by task path, not file path
- keep verification points while replacing examples
- make planning, permissions, recovery, and rollback a closed loop
- treat independent verification as a system constraint, not an afterthought
If you bring those principles back into your own reading, it becomes much easier to separate product surface from the real harness skeleton underneath.
