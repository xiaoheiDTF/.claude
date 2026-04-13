# Claude-Code / Workflows / E2e-Testing

> 来源: claudecn.com

# E2E Testing Workflow: Playwright Journeys and Artifact Management

The value of end-to-end (E2E) tests isn’t “coverage percentage”—it’s ensuring critical user journeys work end-to-end, and producing traceable evidence on failure (screenshots/video/trace). A practical E2E approach boils down to three things: **journey inventory, stability, and artifact management**.

## When you must do E2E

At minimum, cover these high-risk journeys:

- login/auth/logout
- orders/payments/transactions
- create/edit/delete (critical data writes)
- search/filter (high-traffic entry points, especially with async/cache)
## A recommended E2E loop (copyable)

- Write user journeys and acceptance checkpoints (don’t start with code)
- Generate/maintain Playwright tests
- Run locally 3–5 times to confirm stability
- Run in CI (retain artifacts on failure)
- If flaky: quarantine first, then fix (don’t drag down the main CI line)
## Page Object Model (POM) suggestion

The key idea: keep locators and actions in page objects; keep test files clean. Example (excerpt):

```typescript
export class MarketsPage {
  async goto() {
    await this.page.goto('/markets')
    await this.page.waitForLoadState('networkidle')
  }
}
```

## Stability: prefer “wait for conditions” over “hard sleep”
Typical flaky causes and fixes:

- races: prefer Playwright’s auto-waiting locator().click()
- network timing: use explicit waitForResponse
- animations: avoid relying on animation timing (disable/reduce if necessary)
Example (excerpt):

```typescript
await page.waitForResponse(resp => resp.url().includes('/api/markets'))
```

## Artifacts: make failures reproducible
On failures, retain:

- screenshot
- video
- trace (step-by-step replay)
- HTML report / JUnit XML (for CI display/aggregation)
This dramatically reduces “CI is red, but why?” debugging cost.

## Flaky quarantine suggestions

Two common approaches (excerpts):

```typescript
test.fixme(true, 'Test is flaky - Issue #123')
```

or skip only in CI:

```typescript
test.skip(process.env.CI, 'Test is flaky in CI - Issue #123')
```

## Next steps

- put E2E into your team loop: see Quality gates
- fix build failures incrementally first: see Build troubleshooting
## Reference

- Related pages on this site:Quality gates
- Build troubleshooting
