# Claude-Code / Workflows / Security-Review

> 来源: claudecn.com

# Security Review Workflow: From Secrets to OWASP

The goal of security review is not “security education”—it’s turning risk into an **actionable checklist** and an **enforceable merge gate**. This page presents a team-executable process.

## When you must do a security review

If any of the following applies:

- new/changed API endpoints
- processing user input (query params, forms, file uploads)
- authN/authZ changes
- database query/write logic changes
- adding/upgrading dependencies (possible CVEs)
- money/payment/transaction flows
## A recommended security review loop (copyable)

- Run automated checks first: dependency vulnerabilities, secrets scanning, basic rule scans
- Do human review next: use an OWASP Top 10 lens for common high-risk areas
- Produce a severity-graded report: CRITICAL/HIGH must block merge
- Add tests and verification: at least cover error paths and boundary conditions
## Automated checks (examples)

From `security-reviewer` (excerpt):

```bash
# High severity only
npm audit --audit-level=high
```

And a simple grep for secrets (excerpt):

```bash
grep -r "api[_-]?key\\|password\\|secret\\|token" --include="*.js" --include="*.ts" --include="*.json" .
```

Reminder: these checks have false positives/negatives and can’t replace human review. Also, never commit real secrets (see [Security guide](https://claudecn.com/en/docs/claude-code/reference/security/)).

## Human review focus: three common and deadly classes

### 1) Hardcoded secrets (CRITICAL)

Example (excerpt):

```javascript
// ❌ CRITICAL: Hardcoded secrets
const apiKey = "sk-proj-xxxxx"
const password = "admin123"
const token = "ghp_xxxxxxxxxxxx"
```

### 2) SQL injection (CRITICAL)
Example (excerpt):

```javascript
// ❌ CRITICAL: SQL injection vulnerability
const query = `SELECT * FROM users WHERE id = ${userId}`
await db.query(query)
```

### 3) SSRF (HIGH)
Example (excerpt):

```javascript
// ✅ CORRECT: Validate and whitelist URLs
const allowedDomains = ['api.example.com', 'cdn.example.com']
const url = new URL(userProvidedUrl)
if (!allowedDomains.includes(url.hostname)) {
  throw new Error('Invalid URL')
}
const response = await fetch(url.toString())
```

## Report format: an actionable severity-graded output
The template can vary, but standardize at least:

- Summary: counts for Critical/High/Medium/Low + overall risk level
- Blocking: CRITICAL/HIGH items with locations and fix guidance
- Checklist: quick pass/fail gate
To embed this in your team loop, run it together with [Quality gates](https://claudecn.com/en/docs/claude-code/workflows/quality-gates/): if CRITICAL/HIGH exists, don’t merge.

## Reference

- Related pages on this site:Security guide
- Quality gates
