# Source-Analysis / Cost-Usage

> 来源: claudecn.com

# Cost Tracking

`cost-tracker.ts` (323 lines) is an often-overlooked but pervasive cross-cutting concern. It’s not just “recording how much was spent” — it’s a complete 7-dimension session-level metering system.

## Core Question

Every API call, every tool execution, every code change an AI agent makes has a cost. Users need to know “how much did this session cost,” the system needs to know “how much can still be spent,” and operations needs to know “where anomalous consumption occurred.”

Cost tracking is not an add-on but infrastructure for sustainable agent operation.

## 7-Dimension Metering

| Dimension | Description |
| --- | --- |
| **Token metering** | Input tokens, output tokens, cache creation tokens, cache read tokens tracked separately |
| **Time decomposition** | Total elapsed, API call time, retry-excluded API time, tool execution time computed independently |
| **Code changes** | Lines added and lines deleted, continuously accumulated |
| **Multi-model split** | Usage bucketed by model name, queryable via `getUsageForModel()` |
| **Cost estimation** | `calculateUSDCost()` based on model pricing tables for real-time USD cost |
| **Web Search** | Independent web search request count tracking |
| **State persistence** | `setCostStateForRestore()` / `resetCostState()` for session resume and reset |

## Architecture

```
Consumers → cost-tracker.ts → Event Sources → API Calls → token metering → Tool Execution → time metering → Code Changes → line counting → Web Search → request counting → Global State Atom → bootstrap/state.js → Multi-Model Bucketing → getUsageForModel() → Cost Estimation → calculateUSDCost() → Status Bar → real-time cost display → Session Persistence → resume/reset → Telemetry Pipeline → logEvent()
```

### Global State Atom

The cost tracker uses a global state atom in `bootstrap/state.js`. Any module can read current session cost via `getTotalCostUSD()` without passing counter references. This is a typical **cross-cutting concern globalization** design — cost information needs to be simultaneously available in the UI layer (status bar), runtime layer (budget checks), and telemetry layer (reporting).

### Two Token Counting Methods

| Method | Scenario | Precision |
| --- | --- | --- |
| **Canonical** | From API response `usage` field | Exact |
| **Rough estimation** | Pre-request estimation, image/document estimation | Approximate |

Rough estimation rules:

- Plain text: 4 bytes/token
- JSON format: 2 bytes/token (dense formats need more conservative estimation)
- Images/documents: Conservative 2,000 tokens (actual formula: width × height / 750)
### Multi-Model Bucketing

When a session involves multiple models (primary model + sub-agent model + YOLO classifier model), the cost tracker buckets by model name. `getUsageForModel()` supports per-model usage queries.

## Relationship to Runtime

Cost tracking is not an isolated recorder but interacts with multiple runtime subsystems:

| Interaction Target | Relationship |
| --- | --- |
| **Auto compression** | Compression decisions consider current token consumption rate |
| **Token budget** | `MAX_TOOL_RESULTS_PER_MESSAGE_CHARS = 200K` prevents single-tool flooding |
| **Telemetry** | API three-event model (query/success/error) + TTFT/TTLT performance metrics |
| **Session resume** | `setCostStateForRestore()` restores accumulated cost on resume |
| **Status bar** | Real-time display of current session USD cost |

## Observability Connection

Cost tracking is one data source in Claude Code’s 5-layer telemetry system. After each API call, `logEvent()` reports token usage, timing, and cost to the telemetry pipeline, which flows through PII filtering to Datadog and internal data lakes.

Key metrics:

- TTFT (Time to First Token): First token latency
- TTLT (Time to Last Token): Last token latency
- Cache hit rate: cacheReadTokens / totalInputTokens
## Lessons for Agent Builders

| Pattern | Description |
| --- | --- |
| **Cross-cutting metering** | Cost tracking should be as ubiquitous as logging, not bolted on later |
| **Multi-dimensional bucketing** | Don’t just track total tokens — bucket by model, time, and change type |
| **Conservative estimation** | When precise data is unavailable, use conservative fallbacks (JSON at 2 bytes/token) |
| **Session persistence** | Cost state must survive resume, otherwise users see discontinuous billing |
| **Globally readable** | Global state atoms let any module read cost without manual parameter passing |

## Path Evidence

| Path | Role |
| --- | --- |
| `src/cost-tracker.ts` | Core cost tracker (323 lines) |
| `src/bootstrap/state.js` | Global state atom |
| `src/utils/modelCost.ts` | Model pricing table |
| `src/services/analytics/` | Telemetry pipeline |
| `src/components/` | Status bar display |

## Further Reading

- Runtime Loop — Where cost tracking sits in queryLoop
- Architecture Map — Cross-cutting concern system positioning
- Memory System — Compression and cost relationship
