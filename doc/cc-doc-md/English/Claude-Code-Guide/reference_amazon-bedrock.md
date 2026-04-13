# Claude-Code / Reference / Amazon-Bedrock

> 来源: claudecn.com

# Amazon Bedrock

How to run Claude Code on **Amazon Bedrock** (credentials, IAM, common troubleshooting), and how to use **Bedrock Guardrails** for content filtering.

## Prerequisites

- Your AWS account has Bedrock enabled and you have access to the required Claude models
- You have working AWS credentials (Access Key / SSO / Console / Bedrock API key, etc.)
- Your IAM permissions allow calling Bedrock (see below)
## Setup

### 1) First-time use: submit a Use Case (one-time)

For Anthropic models on Bedrock, you typically need to submit use case information the first time you use the model (usually once per account). In the Bedrock console, open the Chat/Text playground, select an Anthropic model, and follow the prompts.

### 2) Configure AWS credentials

Claude Code uses the AWS SDK default credential chain. Options include:

- AWS CLI: aws configure
- environment variables: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN
- SSO: aws sso login --profile 
 and set AWS_PROFILE=
- Bedrock API key: AWS_BEARER_TOKEN_BEDROCK=
#### Advanced: auto-refresh SSO/enterprise credentials
When Claude Code detects expired credentials (based on local timestamps or Bedrock auth errors), it can run a configured script to refresh:

- awsAuthRefresh: for commands that update ~/.aws (e.g., aws sso login ...)
- awsCredentialExport: for environments that can’t write ~/.aws and must print temporary credential JSON directly
Example (`settings.json`):

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": {
    "AWS_PROFILE": "myprofile"
  }
}
```

### 3) Enable Bedrock (environment variables)
At minimum:

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

Optional: configure a separate region for the “small/fast” model:

```bash
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
```

`AWS_REGION` is required. Claude Code does not read this from `~/.aws` config files.

## Recommended token settings (Bedrock)
Official recommendation:

```bash
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024
```

## Minimal IAM policy (example)
Example IAM policy that allows Claude Code to call Bedrock:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowModelAndInferenceProfileAccess",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListInferenceProfiles"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*",
        "arn:aws:bedrock:*:*:foundation-model/*"
      ]
    },
    {
      "Sid": "AllowMarketplaceSubscription",
      "Effect": "Allow",
      "Action": [
        "aws-marketplace:ViewSubscriptions",
        "aws-marketplace:Subscribe"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:CalledViaLast": "bedrock.amazonaws.com"
        }
      }
    }
  ]
}
```

A more strict approach is to scope `Resource` down to the inference profile ARNs you actually use.

## Bedrock Guardrails (content filtering)

Bedrock Guardrails can add content filtering for Claude Code. After you create and publish a Guardrail in the Bedrock console, inject the relevant headers into `settings.json` via `ANTHROPIC_CUSTOM_HEADERS`:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

If you use cross-region inference profiles, Guardrails must also be enabled for cross-region inference.

## Common troubleshooting

- Region issues: confirm inference profiles are available in your region; switch AWS_REGION if needed
- “on-demand throughput isn’t supported”: use an inference profile ID instead of on-demand
- Claude Code on Bedrock uses Invoke APIs (not Converse APIs)
## References

- AWS Bedrock documentation (overview)
- AWS Bedrock Guardrails documentation
- AWS Bedrock inference profiles documentation
- AWS Bedrock IAM / security documentation
