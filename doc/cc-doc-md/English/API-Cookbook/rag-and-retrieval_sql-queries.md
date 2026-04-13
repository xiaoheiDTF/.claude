# Cookbook / Rag-And-Retrieval / Sql-Queries

> 来源: claudecn.com

# SQL queries

Use this page when you already know SQL is the right interface and want practical patterns for making generation safer and more repeatable.

Compared with general Text-to-SQL discussions, this example is more operational: how to present schema context, how to keep execution bounded, and how to make outputs usable in real workflows.

## What to focus on

- How to supply schema context without leaking sensitive data
- Guardrails for execution (read-only, limits, parameterization)
- Making SQL output deterministic enough for automation
## When it works well

- Your team already uses SQL heavily in analysis or reporting
- You need practical safeguards more than model novelty
- Generated queries will feed into scripts, dashboards, or automated jobs
## If you want to reproduce it locally

After your local Cookbook environment is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=misc/how_to_make_sql_queries.ipynb
```
