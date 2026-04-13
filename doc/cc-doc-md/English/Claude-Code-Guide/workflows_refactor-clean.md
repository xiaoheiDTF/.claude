# Claude-Code / Workflows / Refactor-Clean

> 来源: claudecn.com

# Safely Cleaning Dead Code: Tool Evidence + Deletion Log

Dead-code cleanup is high-reward and high-risk: do it right and your codebase gets lighter; do it wrong and production breaks in hard-to-debug ways. A practical operational approach is: **use tools to prove “unused”, delete in small batches, verify with tests, and maintain a deletion log**.

## 1) Gather evidence first: run dead-code tools in parallel

Common evidence sources:

- knip: unused files/exports/deps/types
- depcheck: unused dependencies
- ts-prune: unused TypeScript exports
- eslint: unused variables / unused disable directives
Operationalize this as a command (like `/refactor-clean`): run tools → generate report → proceed to deletion.

## 2) Risk grading: SAFE / CAUTION / DANGER

Grade before deleting:

- SAFE: clearly unreferenced internal exports, unused deps, test helpers (confirm CI impact)
- CAUTION: components/routes/shared utilities (dynamic refs may exist)
- DANGER: configs, entrypoints, public APIs, framework-convention directories
Start with SAFE only; do one category at a time; verify after each batch.

## 3) Deletion cadence: batch + verify + rollbackable

A safe cadence:

- before deletion: run full test/build to ensure baseline is green
- delete a small batch
- rerun tests/build immediately
- if it fails: rollback to the previous batch, then narrow down
Principle: don’t mix “dead-code cleanup” with “business refactors” in the same batch.

## 4) Maintain a deletion log: make cleanup traceable

Keep a log file (example: `docs/DELETION_LOG.md`) containing:

- what was removed (files/exports/deps)
- why it’s safe (tool report, search evidence)
- what replaced it (if deduped)
- impact assessment and verification (build/test results)
This reduces the “six months later nobody knows why” cost.

## 5) Common mis-deletion risks (double-check)

- dynamic imports / string-path references (grep won’t find)
- framework entrypoints (Next.js routes, plugin registration, config loading)
- CLI/script entrypoints (CI uses them, app code doesn’t)
- docs/codegen pipelines (used at build/release time)
When unsure, mark as “candidate” first rather than deleting.

## Reference

- Related pages on this site:Quality gates
