# Computer-Use

> 来源: claudecn.com

# Computer Use

Computer Use enables Claude to interact with [ computer](#) environments through screenshot capabilities and mouse/keyboard control for autonomous desktop interaction.

**Beta Feature**: Computer Use is currently in beta and requires a beta header:

- "computer-use-2025-01-24" (Claude 4 models and Claude Sonnet 3.7)
- "computer-use-2024-10-22" (Claude Sonnet 3.5 [deprecated])

## Overview

Computer Use is a beta feature that enables Claude to interact with desktop environments. This tool provides:

- Screenshot capture: See what’s currently displayed on screen
- Mouse control: Click, drag, and move the cursor
- Keyboard input: Type text and use keyboard shortcuts
- Desktop automation: Interact with any application or interface
While Computer Use can be augmented with other tools like bash and text editor for more comprehensive automation workflows, Computer Use specifically refers to the computer use tool’s capability to see and control desktop environments.

## Model Compatibility

Computer Use is available for the following Claude models:

| Model | Tool Version | Beta Flag |
| --- | --- | --- |
| Claude 4 models | `computer_20250124` | `computer-use-2025-01-24` |
| Claude Sonnet 3.7 | `computer_20250124` | `computer-use-2025-01-24` |
| Claude Sonnet 3.5 v2 (deprecated) | `computer_20241022` | `computer-use-2024-10-22` |

**Model Optimization**: Claude 4 models use updated tool versions optimized for the new architecture. Claude Sonnet 3.7 introduces additional capabilities including the thinking feature for more insight into the model’s reasoning process.

**Version Compatibility**: Older tool versions are not guaranteed to be backwards-compatible with newer models. Always use the tool version that corresponds to your model version.

## Security Considerations

**Security Risks**: Computer Use is a beta feature with unique risks distinct from standard API features. These risks are heightened when interacting with the internet. To minimize risks, consider taking precautions such as:

- Isolated Environment: Use a dedicated virtual machine or container with minimal privileges to prevent direct system attacks or accidents.
- Protect Sensitive Data: Avoid giving the model access to sensitive data, such as account login information, to prevent information theft.
- Limit Network Access: Limit internet access to an allowlist of domains to reduce exposure to malicious content.
- Human Confirmation: Ask a human to confirm decisions that may result in meaningful real-world consequences as well as any tasks requiring affirmative consent, such as accepting cookies, executing financial transactions, or agreeing to terms of service.
**Prompt Injection Risks**: In some circumstances, Claude will follow commands found in content even if it conflicts with the user’s instructions. For example, Claude instructions on webpages or contained in images may override instructions or cause Claude to make mistakes.

We suggest taking precautions to isolate Claude from sensitive data and actions to avoid risks related to prompt injection. We’ve trained the model to resist these prompt injections and have added an extra layer of defense. If you use our Computer Use tools, we’ll automatically run classifiers on your prompts to flag potential instances of prompt injections.

If you’d like to opt out and turn it off, please [contact us](https://support.claude.com/en/).

Finally, please inform end users of relevant risks and obtain their consent prior to enabling Computer Use in your own products.

## Quick Start

### Reference Implementation

We provide a Computer Use reference implementation that includes a web interface, Docker container, example tool implementations, and an agent loop.
[Computer Use Reference Implementation](https://github.com/anthropics/anthropic-quickstarts/tree/main/computer-use-demo)

**Update Note**: The implementation has been updated to include new tools for both Claude 4 models and Claude Sonnet 3.7. Be sure to pull the latest version of the repo to access these new features.

### Basic Usage Example

```python
import anthropic

client = anthropic.Anthropic()

response = client.beta.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=1024,
    tools=[
        {
          "type": "computer_20250124",
          "name": "computer",
          "display_width_px": 1024,
          "display_height_px": 768,
          "display_number": 1,
        },
        {
          "type": "text_editor_20250124",
          "name": "str_replace_editor"
        },
        {
          "type": "bash_20250124",
          "name": "bash"
        }
    ],
    messages=[
        {
            "role": "user",
            "content": "Open a browser and navigate to example.com"
        }
    ],
    betas=["computer-use-2025-01-24"]
)
```

## Tool Definition

### Computer Tool

```python
{
    "type": "computer_20250124",
    "name": "computer",
    "display_width_px": 1024,  # Display width in pixels
    "display_height_px": 768,   # Display height in pixels
    "display_number": 1         # X11 display number (optional)
}
```

### Supported Actions
The Computer Use tool supports the following actions:

| Action | Description | Example |
| --- | --- | --- |
| `key` | Press a keyboard key | `{"action": "key", "text": "Return"}` |
| `type` | Type text | `{"action": "type", "text": "Hello"}` |
| `mouse_move` | Move mouse | `{"action": "mouse_move", "coordinate": [100, 200]}` |
| `left_click` | Left click | `{"action": "left_click"}` |
| `left_click_drag` | Drag | `{"action": "left_click_drag", "coordinate": [300, 400]}` |
| `right_click` | Right click | `{"action": "right_click"}` |
| `middle_click` | Middle click | `{"action": "middle_click"}` |
| `double_click` | Double click | `{"action": "double_click"}` |
| `screenshot` | Take screenshot | `{"action": "screenshot"}` |
| `cursor_position` | Get cursor position | `{"action": "cursor_position"}` |

## Use Cases

### 1. Web Automation

```python
# Automated form filling
response = client.beta.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=2048,
    tools=[computer_tool],
    messages=[{
        "role": "user",
        "content": "Go to example.com/signup and fill out the registration form with username 'testuser' and email 'test@example.com'"
    }],
    betas=["computer-use-2025-01-24"]
)
```

### 2. Application Testing

```python
# Automated UI testing
response = client.beta.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=2048,
    tools=[computer_tool],
    messages=[{
        "role": "user",
        "content": "Open the calculator app, perform the calculation 123 + 456, and verify the result is 579"
    }],
    betas=["computer-use-2025-01-24"]
)
```

### 3. Data Collection

```python
# Extract information from websites
response = client.beta.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=2048,
    tools=[computer_tool],
    messages=[{
        "role": "user",
        "content": "Visit news.example.com and collect all news headlines from the homepage"
    }],
    betas=["computer-use-2025-01-24"]
)
```

### 4. Workflow Automation

```python
# Automate office tasks
response = client.beta.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=2048,
    tools=[computer_tool, text_editor_tool, bash_tool],
    messages=[{
        "role": "user",
        "content": "Open report.docx, find all paragraphs containing 'TODO', extract them and save to todos.txt"
    }],
    betas=["computer-use-2025-01-24"]
)
```

## Best Practices

### 1. Clear Instructions
Provide clear, specific steps:

```python
# ✅ Good instruction
"Open Chrome browser, go to example.com, click the 'Login' button at the top of the page, and enter 'testuser' in the username field"

# ❌ Vague instruction
"Log in to the website"
```

### 2. Error Handling
Implement retry and error recovery mechanisms:

```python
max_retries = 3
for attempt in range(max_retries):
    try:
        response = client.beta.messages.create(
            model="claude-sonnet-4-5",
            max_tokens=2048,
            tools=[computer_tool],
            messages=messages,
            betas=["computer-use-2025-01-24"]
        )
        break
    except Exception as e:
        if attempt == max_retries - 1:
            raise
        time.sleep(2 ** attempt)
```

### 3. Security Isolation
Run in an isolated environment:

```bash
# Use Docker container
docker run -it --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  anthropic/computer-use-demo
```

### 4. Monitoring and Logging
Log all operations for debugging and auditing:

```python
for block in response.content:
    if block.type == "tool_use":
        print(f"Tool: {block.name}")
        print(f"Input: {block.input}")
```

## Combining with Other Tools

### With Bash Tool

```python
tools = [
    {
        "type": "computer_20250124",
        "name": "computer",
        "display_width_px": 1024,
        "display_height_px": 768
    },
    {
        "type": "bash_20250124",
        "name": "bash"
    }
]

# Claude can execute command-line operations while using computer use
```

### With Text Editor

```python
tools = [
    {
        "type": "computer_20250124",
        "name": "computer",
        "display_width_px": 1024,
        "display_height_px": 768
    },
    {
        "type": "text_editor_20250124",
        "name": "str_replace_editor"
    }
]

# Claude can edit files and see results in the UI
```

## Limitations and Considerations

### Current Limitations

- Performance: Complex UI interactions may require multiple iterations
- Accuracy: May be inaccurate when clicking small targets or dense UI elements
- Text Recognition: Limited OCR capabilities, may not recognize all text
- Dynamic Content: May have difficulty handling animations or rapidly changing content
### Unsupported Operations

- Accessing system resources requiring special permissions
- Direct hardware device manipulation
- Bypassing  operating system security restrictions
- Interacting with proprietary or encrypted content
## Pricing
[ Computer](#) Use tool token billing:

- Input tokens: Billed at standard input price
- Output tokens: Billed at standard output price
- Image processing: Screenshots billed as image tokens
**Cost Optimization**:

- Only use screenshots when necessary
- Set reasonable max_tokens
- Consider using smaller display resolutions

## FAQ

### Q: Can Computer Use work on any operating system?

**A:** Computer Use is primarily optimized and tested for Linux environments. While it can theoretically work on other [ operating systems](#), we recommend using Linux (especially in Docker containers) for the best experience.

### Q: How to handle operations requiring human confirmation?

**A:** Implement human confirmation mechanisms in the agent loop:

```python
if requires_confirmation(action):
    user_approval = input(f"Confirm execution: {action}? (y/n): ")
    if user_approval.lower() != 'y':
        continue
```

### Q: Can Computer Use access the internet?
**A:** Yes, but it’s strongly recommended to limit internet access to an allowlist of domains to reduce security risks.

## Related Resources

- Claude API Documentation
- Tool Use Documentation
- Extended Thinking
- Agent Skills
## Next Steps

- Explore Extended Thinking to enhance Claude’s reasoning capabilities
- Learn about Agent Skills to build reusable skill systems
- Check out Cookbook for more automation examples
