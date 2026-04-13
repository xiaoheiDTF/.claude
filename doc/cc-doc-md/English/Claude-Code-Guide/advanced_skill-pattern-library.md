# Claude-Code / Advanced / Skill-Pattern-Library

> 来源: claudecn.com

# Pattern Library: Turn Engineering Practices into Skills

For many teams, the bottleneck isn’t “writing code”—it’s repeatedly re-explaining the same engineering standards: how APIs are designed, how data access works, how components are organized, and how to avoid common pitfalls. A more sustainable approach is to codify these practices as Skills so Claude can apply them automatically on each task.

This page presents a team-friendly structure for turning engineering practices into Skills (constraints, templates, and checklists).

## 1) Don’t write Skills as encyclopedias—write constraints, templates, and checklists

A useful Skill usually has three parts:

- When to use: which scenarios must use it (new APIs, refactors, perf work)
- Patterns: team-approved patterns with small code templates
- Checklist: must-pass checks before completion (validation, errors, tests)
## 2) Backend patterns (excerpt): API / repository / N+1 / caching

### RESTful API shape (example)

```typescript
GET    /api/markets                 # List resources
GET    /api/markets/:id             # Get single resource
POST   /api/markets                 # Create resource
PUT    /api/markets/:id             # Replace resource
PATCH  /api/markets/:id             # Update resource
DELETE /api/markets/:id             # Delete resource
```

### Repository pattern (example)

```typescript
interface MarketRepository {
  findAll(filters?: MarketFilters): Promise<Market[]>
  findById(id: string): Promise<Market | null>
  create(data: CreateMarketDto): Promise<Market>
  update(id: string, data: UpdateMarketDto): Promise<Market>
  delete(id: string): Promise<void>
}
```

### Avoid N+1 (example)

```typescript
const markets = await getMarkets()
const creatorIds = markets.map(m => m.creator_id)
const creators = await getUsers(creatorIds)  // 1 query
const creatorMap = new Map(creators.map(c => [c.id, c]))

markets.forEach(market => {
  market.creator = creatorMap.get(market.creator_id)
})
```

Rollout tip: put “avoid N+1” into the backend Skill checklist so Claude flags it while writing query code.

## 3) Frontend patterns (excerpt): composition and custom hooks

### Composition over inheritance (example)

```typescript
export function Card({ children, variant = 'default' }: CardProps) {
  return <div className={`card card-${variant}`}>{children}</div>
}
```

### Debounce hook (example)

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```

Rollout tip: don’t stuff the frontend Skill with UI trivia—encode boundaries, state patterns, and performance basics (avoid unnecessary renders, avoid deep prop drilling, etc.).

## 4) Make Skills actually apply (not just sit in a folder)

Turn Skills into part of your workflow:

- In CLAUDE.md, specify which tasks must use which Skills (“new API must apply backend patterns”).
- Codify workflows as /command entrypoints (e.g. /plan, /code-review) so checklists naturally run.
- Use Hooks to remind on common omissions (console.log, format, typecheck).
Related pages:

- Agent Skills
- Team Starter Kit
- Quality gates
## 5) Advanced (optional): auto-suggest Skills on UserPromptSubmit

A common failure mode: Skills exist but aren’t used. One practical approach is to run a lightweight matcher on `UserPromptSubmit` that only **suggests** Skills instead of auto-enabling them:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/skill-eval.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
```

Rules live in `.claude/hooks/skill-rules.json` (excerpt):

```json
{
  "config": { "minConfidenceScore": 3, "maxSkillsToShow": 5 },
  "scoring": { "keyword": 2, "pathPattern": 4, "intentPattern": 4 }
}
```

Rollout tips:

- keep it as a “reminder guardrail”, not an automatic enabler
- start with 5–10 core Skills (keywords/paths/intents), not everything
## 6) A human-friendly Skills index and “skill bundles” (recommended)

If you only write `SKILL.md` but don’t provide an index:

- new team members don’t know what exists
- nobody knows which Skills to combine for a task
Maintain a `.claude/skills/README.md` listing Skills by category and showing “recommended bundles” (example):

```text
### Building a New Feature
1. react-ui-patterns
2. graphql-schema
3. core-components
4. testing-patterns
```

Start with a 10-line minimal index (name + one-line purpose + recommended bundle) and expand over time.

## Reference

- Claude Code Skills (official): https://code.claude.com/docs/en/skills
- Related pages on this site:Agent Skills
- Hooks
