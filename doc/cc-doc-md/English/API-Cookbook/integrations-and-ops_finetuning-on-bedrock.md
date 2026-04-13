# Cookbook / Integrations-And-Ops / Finetuning-On-Bedrock

> 来源: claudecn.com

# Fine-tuning on Amazon Bedrock

Walks through fine-tuning Claude 3 Haiku on Amazon Bedrock (dataset prep → S3 upload → job launch → usage).

- Upstream notebook: finetuning/finetuning_on_bedrock.ipynb
## What to focus on

- Dataset hygiene (quality, privacy, labeling)
- Operational steps (S3, job lifecycle)
- How to evaluate fine-tuned behavior vs baseline
## Run locally

```bash
make test-notebooks NOTEBOOK=finetuning/finetuning_on_bedrock.ipynb
```
