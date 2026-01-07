# Verbose Mode Guide

## Overview

Verbose mode provides detailed output of all command execution results without the bash trace (`set -x`) overhead. It's perfect for understanding what's happening during demo execution while keeping output readable.

## Key Differences

| Feature | Debug Mode (`--debug`) | Verbose Mode (`--verbose`) |
|---------|----------------------|---------------------------|
| Bash trace (`set -x`) | ✅ Yes | ❌ No |
| Command output | ✅ Yes | ✅ Yes |
| Execution flow | ✅ Detailed | ✅ Simplified |
| AI generation output | ❌ Hidden | ✅ Visible (with `tee`) |
| Validation logs | ✅ Yes | ✅ Yes |
| Best for | Deep debugging | Understanding flow |

## Usage

### Basic Usage

```bash
# Enable verbose mode
./demo.sh --verbose

# With run-demo.sh
./run-demo.sh --verbose

# Non-interactive with verbose
./run-demo-auto.sh --verbose

# Test script with verbose
./test-copilot.sh --verbose
```

### Combined Flags

```bash
# Verbose + custom retries
./demo.sh --verbose --max-retries 5

# Debug + verbose (gets both trace and output)
./demo.sh --debug --verbose

# All flags together
./demo.sh --verbose --debug --max-retries 10
```

### Non-Interactive Mode

```bash
# Verbose non-interactive
./run-demo-auto.sh --verbose

# Shows:
# - [AUTO-WAIT: 3s], [AUTO-WAIT: 4s], etc.
# - Full AI generation output
# - Validation results
```

## What Verbose Shows

### Phase Execution

```
[VERBOSE] Starting generation for Business Requirements (attempt 1/3)
[VERBOSE] Prompt file: prompts/01-concept.txt
[VERBOSE] Output file: output/requirements.md
[VERBOSE] Executing: cat prompts/01-concept.txt | copilot --allow-all-tools
```

### AI Generation Output

In verbose mode, AI generation output is displayed in real-time using `tee`:

```bash
# Without verbose: output hidden
cat prompt.txt | copilot --allow-all-tools > output.md

# With verbose: output visible AND saved
cat prompt.txt | copilot --allow-all-tools | tee output.md
```

You'll see the AI's response as it's generated, helpful for:
- Verifying AI is working correctly
- Watching generation progress
- Understanding what content is being created

### Auto-Wait Notifications

In non-interactive mode with verbose:

```
[AUTO-WAIT: 4s]
[AUTO-WAIT: 3s]
[AUTO-WAIT: 5s]
```

Shows random 3-5 second delays replacing manual `read` prompts.

### Validation Logs

```
[VERBOSE] Running validation: validate_requirements
[VERBOSE] File validation passed: output/requirements.md
✅ Business Requirements completed successfully
```

## Use Cases

### 1. Presentations with Transparency

Show the audience what's happening:

```bash
./demo.sh --verbose
```

They'll see:
- What commands are being run
- AI generation in real-time
- Validation checks passing
- Auto-wait delays (in non-interactive mode)

### 2. Development and Testing

Understand execution flow:

```bash
./run-demo-auto.sh --verbose
```

Helps you:
- Verify AI is generating expected content
- Spot validation issues
- Check timing of auto-waits
- Debug without excessive trace output

### 3. CI/CD Pipelines

Get detailed logs without bash trace noise:

```bash
# In your CI script
./run-demo-auto.sh --verbose --max-retries 10 > demo.log 2>&1
```

### 4. Learning Mode

Understand how the demo works:

```bash
./demo.sh --verbose --max-retries 2
```

See each step's execution without overwhelming detail.

## Verbose Output Examples

### Successful Generation

```
📋 PHASE 1: Business Concept & Requirements
[VERBOSE] Starting generation for Business Requirements (attempt 1/3)
[VERBOSE] Prompt file: prompts/01-concept.txt
[VERBOSE] Output file: output/requirements.md
[VERBOSE] Executing: cat prompts/01-concept.txt | copilot --allow-all-tools

# Business Requirements Document
...
[AI output streamed here in real-time]
...

[VERBOSE] Copilot generation completed
[VERBOSE] Running validation: validate_requirements
[VERBOSE] File validation passed: output/requirements.md
✅ Business Requirements completed successfully
```

### Generation with Retry

```
[VERBOSE] Starting generation for Flask Implementation (attempt 1/3)
[VERBOSE] Prompt file: prompts/03-implementation.txt
[VERBOSE] Output file: output/implementation.log
[VERBOSE] Executing: cat prompts/03-implementation.txt | copilot --allow-all-tools
❌ ERROR: app.py doesn't appear to be a Flask application
⚠️  WARNING: Retry attempt 2 of 3 for Flask Implementation

[VERBOSE] Starting generation for Flask Implementation (attempt 2/3)
[VERBOSE] Executing: cat prompts/03-implementation.txt | copilot --allow-all-tools
...
✅ Flask Implementation completed successfully
```

### Auto Mode with Verbose

```
# Sending to AI agent for requirements analysis...
[VERBOSE] Starting generation for Business Requirements (attempt 1/3)
[VERBOSE] Executing: cat prompts/01-concept.txt | copilot --allow-all-tools
[AI output displayed]
✅ Business Requirements completed successfully

[AUTO-WAIT: 4s]

# Let's see what the AI generated:
[AUTO-WAIT: 3s]
```

## Combining with Other Flags

### Verbose + Debug

```bash
./demo.sh --verbose --debug
```

Gets you:
- ✅ Bash trace (from `--debug`)
- ✅ Verbose logs (from `--verbose`)
- ✅ AI output visible
- ✅ All validation details

**Best for**: Deep troubleshooting

### Verbose + Max Retries

```bash
./demo.sh --verbose --max-retries 5
```

- ✅ See each retry attempt
- ✅ Watch AI responses
- ✅ More chances for success

**Best for**: Flaky network conditions

### Non-Interactive + Verbose

```bash
./run-demo-auto.sh --verbose
```

- ✅ No manual input needed
- ✅ Random 3-5s waits shown
- ✅ Full output visible
- ✅ AI generation streamed

**Best for**: Automated demos, CI/CD, recordings

## Environment Variables

Verbose mode respects these environment variables:

```bash
# Non-interactive with verbose
NO_WAIT=true TYPE_SPEED=0 ./demo.sh --verbose

# Shows:
# - [AUTO-WAIT: Xs] messages
# - Full command output
# - No typing animation
# - No manual waits
```

## Troubleshooting with Verbose

### Issue: Don't see AI output

**Solution**: Add `--verbose` flag

```bash
# Before: AI output hidden
./demo.sh

# After: AI output visible
./demo.sh --verbose
```

### Issue: Too much output with debug mode

**Solution**: Use verbose instead of debug

```bash
# Too verbose
./demo.sh --debug

# Just right
./demo.sh --verbose
```

### Issue: Need to see what failed

**Solution**: Combine verbose with retries

```bash
./demo.sh --verbose --max-retries 5
```

Each retry attempt shows full output.

### Issue: CI/CD logs incomplete

**Solution**: Verbose with stderr capture

```bash
./run-demo-auto.sh --verbose 2>&1 | tee ci-demo.log
```

## Best Practices

### For Presentations

```bash
# Show what's happening without overwhelming detail
./run-demo.sh --verbose
```

### For Development

```bash
# Quick iterations with visibility
./demo.sh --verbose --max-retries 2
```

### For CI/CD

```bash
# Full logging for troubleshooting
./run-demo-auto.sh --verbose --max-retries 10 > logs/demo.log 2>&1
```

### For Learning

```bash
# See how everything works
./demo.sh --verbose
# Then compare with:
./demo.sh --debug --verbose
```

## Performance Impact

- **Minimal overhead**: Just additional logging
- **No bash trace**: Cleaner than debug mode
- **Real-time output**: Shows AI generation as it happens
- **Auto-wait visible**: See timing in non-interactive mode

## Related Documentation

- [DEBUG_MODE.md](DEBUG_MODE.md) - Deep debugging with bash trace
- [NON_INTERACTIVE_MODE.md](NON_INTERACTIVE_MODE.md) - Automation guide
- [RELIABILITY.md](RELIABILITY.md) - Retry logic and validation
- [README.md](../README.md) - Main documentation

## Summary

Use `--verbose` when you want to:
- ✅ See what commands are running
- ✅ Watch AI generation in real-time
- ✅ Understand execution flow
- ✅ Debug without bash trace noise
- ✅ Show transparency in presentations
- ✅ Monitor auto-wait timing
- ❌ Don't need deep bash-level debugging
