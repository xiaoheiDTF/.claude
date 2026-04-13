# Extended-Thinking

> 来源: claudecn.com

# Extended Thinking

Extended Thinking gives Claude enhanced reasoning capabilities for complex tasks, while providing varying levels of transparency into its step-by-step thought process before it delivers its final answer.

## Supported models

Extended thinking is supported in the following models:

- Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)
- Claude Sonnet 4 (claude-sonnet-4-20250514)
- Claude Sonnet 3.7 (claude-3-7-sonnet-20250219)
- Claude Haiku 4.5 (claude-haiku-4-5-20251001)
- Claude Opus 4.1 (claude-opus-4-1-20250805)
- Claude Opus 4 (claude-opus-4-20250514)
**Model Version Differences**: API behavior differs across Claude Sonnet 3.7 and Claude 4 models, but the API shapes remain exactly the same.

## How extended thinking works
When extended thinking is turned on, Claude creates `thinking` content blocks where it outputs its internal reasoning. Claude incorporates insights from this reasoning before crafting a final response.

The API response will include `thinking` content blocks, followed by `text` content blocks.

### Response Format Example

```json
{
  "content": [
    {
      "type": "thinking",
      "thinking": "Let me analyze this step by step...",
      "signature": "WaUjzkypQ2mUEVM36O2TxuC06KN8xyfbJwyem2dw3URve/op91XWHOEBLLqIOMfFG/UvLEczmEsUjavL...."
    },
    {
      "type": "text",
      "text": "Based on my analysis..."
    }
  ]
}
```

## How to use extended thinking

### Basic Usage Example

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000
    },
    messages=[
        {
            "role": "user",
            "content": "Are there an infinite number of prime numbers such that n mod 4 == 3?"
        }
    ]
)
```

### Key Parameters

| Parameter | Description |
| --- | --- |
| `thinking.type` | Set to `"enabled"` to enable extended thinking |
| `thinking.budget_tokens` | Token budget allocated for thinking process (optional) |
| `max_tokens` | Maximum tokens for response (includes thinking + text) |

## Use Cases
Extended thinking is particularly well-suited for:

### 1. Complex Problem Solving

Mathematical proofs, logical reasoning, algorithm design, and other tasks requiring deep thinking.

```python
# Example: Mathematical problem
message = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=[{
        "role": "user",
        "content": "Prove: There are infinitely many primes p such that p ≡ 3 (mod 4)"
    }]
)
```

### 2. Architecture Design
System design tasks that require weighing multiple options and considering various constraints.

### 3. Debugging Complex Issues

Bug debugging that requires analyzing multi-level error causes and tracking complex dependencies.

### 4. Strategic Planning

Decision tasks that require multi-step reasoning and evaluating different paths.

## Best Practices

### 1. Set Appropriate Token Budget

```python
# Simple problems: smaller budget
thinking={"type": "enabled", "budget_tokens": 2000}

# Complex problems: larger budget
thinking={"type": "enabled", "budget_tokens": 10000}
```

### 2. Process Thinking Content

```python
for block in response.content:
    if block.type == "thinking":
        # Optional: log thinking process for debugging
        print(f"Thinking: {block.thinking}")
    elif block.type == "text":
        # Final answer
        print(f"Answer: {block.text}")
```

### 3. Verify Thinking Authenticity
Extended thinking responses include digital signatures for verifying content authenticity:

```python
thinking_block = response.content[0]
signature = thinking_block.signature
# Use Anthropic's verification method
is_authentic = anthropic.verify_thinking(thinking_block.thinking, signature)
```

## Pricing Information
When using extended thinking:

- Thinking tokens: Billed at output token price
- Budget control: Use budget_tokens to control thinking costs
- Total cost: = Input token cost + Thinking token cost + Output token cost
**Cost Control**: Set `budget_tokens` appropriately to control costs. For tasks that don’t require deep reasoning, consider not enabling extended thinking.

## Combining with Other Features

### With Prompt Caching

```python
response = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 10000},
    system=[
        {
            "type": "text",
            "text": "You are a mathematics expert...",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[...]
)
```

### With Tool Use
Extended thinking can help Claude better plan and execute tool calls:

```python
response = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 5000},
    tools=[...],
    messages=[...]
)
```

## FAQ

### Q: When should I use extended thinking?
**A:** When tasks require:

- Multi-step reasoning
- Weighing multiple options
- Complex logical analysis
- Deep problem solving
For simple queries or creative writing, extended thinking is typically not needed.

### Q: How to balance thinking quality and cost?

**A:**

- Start with smaller budget_tokens for testing
- Adjust budget based on task complexity
- Monitor actual thinking content usage
- Perform cost analysis for batch tasks
### Q: Is thinking content reliable?

**A:**

- Thinking content includes digital signatures for authenticity verification
- The thinking process reflects the model’s actual reasoning
- However, thinking content may still contain errors; evaluate alongside final answer
## Related Resources

- Claude API Documentation
- Prompt Engineering Guide
- Tool Use Documentation
- Model Context Protocol
## Next Steps

- Explore Computer Use to let Claude control desktop environments
- Learn about Agent Skills to build reusable skill systems
- Check out Cookbook for more code examples
