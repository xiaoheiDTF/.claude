# Cookbook / Rag-And-Retrieval / Text-To-Sql

> 来源: claudecn.com

# Text to SQL

Use this pattern when users ask analytical questions in natural language, but your real system boundary is still a database.

The difficulty is rarely only SQL generation. The real work is grounding the model in schema context, constraining execution, and checking whether the answer is actually correct.

## What to focus on

- Getting reliable SQL generation (schema grounding + constraints)
- Evaluating correctness beyond “looks right”
- Defensive execution (validation, limits, safety)
## When it works well

- The question maps to structured data already stored in tables
- You can provide enough schema context without exposing sensitive data
- Safety controls matter as much as answer quality
## If you want to reproduce it locally

After your local Cookbook environment is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=capabilities/text_to_sql/guide.ipynb
```
