# Source-Analysis / Memory

> 来源: claudecn.com

# Memory System

Claude Code’s memory is not an isolated feature — it is a core part of the runtime backbone. The topic here is not just “long context”. It is how the system loads memory, compresses history, preserves boundaries, and resumes work in the next turn.

Visual counterpart: [Runtime page](https://code.claudecn.com/runtime/)

## Why memory is not an accessory

If Claude Code were only a single-turn interface, memory would be an optimization.

Once the system has to support multi-turn tasks, subagents, plan review, and long-session recovery, it needs answers to three questions:

- what should enter context now
- what should survive compaction
- what should be available again in a later turn
That is a state-management problem, not just a transcript-length problem.

## Four subsystems

```
Compaction → Running → Loading → summary → persist → memdir long-term memory → Relevance selection → CLAUDE.md project conventions → Current turn context → query loop execution → SessionMemory state → compact five-layer strategy → extractMemories
```

| Subsystem | Purpose | Representative evidence |
| --- | --- | --- |
| Memory directory | Stores and locates longer-lived memory artifacts | `src/memdir/paths.ts`, `src/memdir/memdir.ts` |
| Relevance selection | Decides which memories should enter the current turn | `src/memdir/memoryScan.ts`, `src/memdir/findRelevantMemories.ts` |
| Session memory | Maintains continuity inside the active conversation | `src/services/SessionMemory/sessionMemory.ts` |
| Compaction and write-back | Preserves resumable structure under token pressure | `src/services/compact/compact.ts`, `src/services/compact/sessionMemoryCompact.ts` |

Together these layers form the real long-session system.

## Runtime loop

- A query begins by loading project instructions, CLAUDE.md, and memdir-backed memory.
- Memory is filtered before it enters context — not simply dumped in full.
- As the conversation grows, compact services rewrite history into a shorter but still resumable form.
- SessionMemory keeps the current session usable after that rewrite.
- Longer-lived extraction paths can promote useful outputs into more durable memory layers.
Claude Code is not merely prepending old messages. It is continuously rewriting what future turns are allowed to see.

## Why compact matters

It is tempting to read compaction as “token pressure relief”. In practice, compaction is responsible for continuity:

- it decides what survives into the next turn
- it decides whether recovery depends on raw history or summarized boundaries
- it decides whether a long task preserves its operating skeleton
That is why `compact.ts`, `sessionMemoryCompact.ts`, and `postCompactCleanup.ts` should be read as runtime continuity components, not utility functions.

## The relation to governance

Governance decides what the system may do. Memory decides what the system can still remember. The first preserves boundaries. The second preserves continuity. Claude Code becomes meaningfully different from a single-turn tool runner only when both layers are present.

## Lessons for agent builders

| Pattern | Description |
| --- | --- |
| **Memory is not full-load** | Relevance selection (`findRelevantMemories`) decides what enters the current turn, preventing context bloat |
| **Compaction is continuity** | Compact is not simple summarization — it determines how much state can be recovered in the next turn |
| **Layered persistence** | Current session → SessionMemory → memdir → team sync, each layer with different lifecycles |
| **Memory and governance co-operate** | Long memory without governance boundaries becomes uncontrollable; governance without memory becomes brittle |

## Path evidence

| Path | Responsibility |
| --- | --- |
| `src/memdir/paths.ts` | Memory file path definitions |
| `src/memdir/memdir.ts` | Memory directory core logic |
| `src/memdir/memoryScan.ts` | Memory scanning and discovery |
| `src/memdir/findRelevantMemories.ts` | Relevance selection |
| `src/services/SessionMemory/sessionMemory.ts` | Session memory object |
| `src/services/compact/compact.ts` | Main compaction logic |
| `src/services/compact/sessionMemoryCompact.ts` | Session memory-specific compaction |
| `src/services/extractMemories/` | Memory extraction |
| `src/services/teamMemorySync/` | Team memory synchronization |

## Further reading

- Runtime Loop — where memory loading and compaction sit in the seven stages
- Execution Governance — governance and memory co-operation
- Hooks & Resilience — resilience mechanisms related to memory recovery
- Signals & Extensions — memory system evolution direction
