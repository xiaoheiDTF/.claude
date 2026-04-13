# Agent-Skills / Best-Practices

> 来源: claudecn.com

# Agent Skills Best Practices

This guide provides best practices for creating high-quality Agent Skills, helping you write clear, efficient, and maintainable Skills.

If you are no longer focused only on one Skill at a time and need a team-friendly entry point for many Skills, read [Team Index Template](team-index-template/) alongside this page.

## Core Principles

### 1. Clear Description

The `description` field is key to Claude deciding when to use a Skill. A good description should:

**✅ Good Description**:

```yaml
---
name: PDF Processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
```

**❌ Poor Description**:

```yaml
---
name: PDF Processing
description: Handles PDF files.
---
```

### Description Writing Tips

- State Functionality: Clearly describe what the Skill does
- Trigger Conditions: Specify when this Skill should be used
- Keywords: Include terms users might use
- Concise: Keep within 1024 characters**Template**:

```
[Functionality description]. Use when [trigger scenario] or when the user mentions [keywords].
```

## Structured Instructions

### Use Clear Hierarchy
**✅ Recommended**:

```markdown
# Skill Name

## Quick Start

### Basic Usage
Step 1: Preparation
Step 2: Execute Task

### Advanced Usage
Step 1: Configuration Options
Step 2: Performance Optimization

## Best Practices

### Performance Optimization
- Recommendation 1
- Recommendation 2

### Error Handling
- Common errors and solutions
```

### Provide Specific Examples
**✅ Include Runnable Code**:

```markdown
## Example: Extract PDF Text

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

**Output**:
```
Page 1 content here...
```
```

**❌ Avoid Abstract Descriptions**:

```markdown
## Example
Use relevant library to read PDF file and extract content.
```

## Progressive Disclosure

### Keep Main Instructions Concise
The body of `SKILL.md` should include:

- Quick start for common features
- Basic workflows
- Common use cases
```markdown
# PDF Processing

## Quick Start

Extract PDF text:
```python
import pdfplumber
with pdfplumber.open("doc.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced Features

Need form filling? See [FORMS.md](FORMS.md)
Need PDF merging? See [MERGE.md](MERGE.md)
```

### Complex Content in Separate Files
Put advanced features, detailed API references in separate files:

```
pdf-skill/
├── SKILL.md          # Main instructions (< 5k tokens)
├── FORMS.md          # Form processing detailed guide
├── MERGE.md          # PDF merging guide
├── REFERENCE.md      # Complete API reference
└── scripts/
    └── utilities.py  # Utility scripts
```

## Code and Scripts

### When to Use Scripts
**Use [ Scripts](#) For**:

- Deterministic operations (file format conversion, data validation)
- Complex algorithms (encryption,  compression)
- Operations requiring specific libraries
**Use Instructions For**:

- Tasks requiring flexible judgment
- Context-dependent decisions
- Creative work
### Script Example

```markdown
## Data Validation

Use validation script to ensure correct data format:

```bash
python scripts/validate.py data.json
```

The script checks:
- JSON format validity
- Required fields exist
- Data types correct
```

## Error Handling

### Clearly State Limitations
**✅ Clear Boundaries**:

```markdown
## Limitations

This Skill has the following limitations:
- No network requests supported
- Only pre-installed Python packages
- Maximum file size: 10MB
- Supported formats: PDF, DOCX, TXT
```

### Provide Solutions

```markdown
## Common Issues

### Issue: File too large causes processing failure

**Symptom**: Error: File size exceeds limit

**Solution**:
```python
# Process large files in chunks
def process_large_file(filepath, chunk_size=1000):
    with open(filepath, 'r') as f:
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            process_chunk(chunk)
```
```

## Testing and Validation

### Include Validation Steps

```markdown
## Verify Results

After completing operations, verify results:

```python
# 1. Check if file was created
assert os.path.exists(output_file), "Output file not created"

# 2. Verify file size
file_size = os.path.getsize(output_file)
assert file_size > 0, "Output file is empty"

# 3. Verify content
with open(output_file, 'r') as f:
    content = f.read()
    assert "expected_content" in content, "Content validation failed"

print("✅ All validations passed")
```
```

## Performance Optimization

### Provide Optimization Recommendations

```markdown
## Performance Optimization

### Large File Processing
Use streaming for large files:

```python
# ❌ Not recommended: Load all at once
with open('large_file.txt', 'r') as f:
    content = f.read()  # May run out of memory
    process(content)

# ✅ Recommended: Streaming
with open('large_file.txt', 'r') as f:
    for line in f:  # Process line by line
        process(line)
```

### Batch Operations
Batch processing improves efficiency:

```python
# ❌ Not recommended: Individual processing
for item in items:
    database.insert(item)  # Multiple database connections

# ✅ Recommended: Bulk insert
database.bulk_insert(items)  # Single connection
```

```
## Security Considerations

### Input Validation

````markdown
## Security

### Input Validation
Always validate user input:

```python
def safe_process(user_input):
    # Validate input type
    if not isinstance(user_input, str):
        raise ValueError("Input must be a string")
    
    # Validate input length
    if len(user_input) > 10000:
        raise ValueError("Input too long")
    
    # Sanitize input
    sanitized = user_input.strip()
    
    return process(sanitized)
```

```
## Checklist

Before releasing a Skill, check these items:

### Required ✅

- [ ] **Clear description**: Includes functionality, triggers, keywords
- [ ] **YAML Frontmatter**: name and description fields correct
- [ ] **Structured content**: Uses headings, lists, code blocks
- [ ] **Runnable examples**: At least one complete working example
- [ ] **State limitations**: Clearly state Skill limitations

### Recommended 🌟

- [ ] **Tiered content**: Simple→Complex organization
- [ ] **External references**: Complex content in separate files
- [ ] **Error handling**: Common issues and solutions
- [ ] **Performance tips**: Optimization techniques and best practices
- [ ] **Validation steps**: How to confirm operations succeeded
- [ ] **Version info**: Record version and update history

### Optimization ⭐

- [ ] **Use cases**: Real-world application scenarios
- [ ] **Complete examples**: End-to-end implementations
- [ ] **Test code**: How to test functionality
- [ ] **Security guide**: Input validation and data protection
- [ ] **Integration guide**: How to work with other tools

## Summary

Keys to writing high-quality Agent Skills:

1. **Clear Description** - Claude knows when to use
2. **Structured Content** - Easy to understand and navigate
3. **Specific Examples** - Directly usable code
4. **Progressive Disclosure** - From simple to complex
5. **Complete Documentation** - Limitations, errors, best practices

Following these best practices, your Skills will be:
- ✅ Easy to use
- ✅ Efficient and reliable
- ✅ Easy to maintain
- ✅ Adaptable

## Next Steps

- **[Create Your First Skill](quickstart)** - Practical application
- **[Skills Examples](../examples/)** - More curated examples in this site
- **[Skills Cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/skills)** - More official examples
- **[API Guide](https://docs.claude.com/en/api/skills-guide)** - Deep dive
```
