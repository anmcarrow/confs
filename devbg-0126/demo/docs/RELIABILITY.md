# Pipeline Reliability Features

## Overview

The demo pipeline now includes comprehensive retry logic and validation to handle failures gracefully. If AI generation fails or produces invalid output, the system automatically retries with exponential backoff.

## Features

### Automatic Retry Logic

- **Default retries**: 3 attempts per phase
- **Configurable**: Use `--max-retries N` to change
- **Exponential backoff**: 2^attempt seconds delay between retries
- **Smart validation**: Each phase has specific validation criteria

### Error Handling

All phases now include:
- File existence validation
- Content validation (checks for expected keywords)
- Automatic regeneration on failure
- Clear error messages with color coding

## Configuration

```bash
# Use default 3 retries
./run-demo.sh

# Custom retry count
./demo.sh --max-retries 5

# Non-interactive with retries
./run-demo-auto.sh --max-retries 5
```

## Validation Per Phase

### Phase 1: Business Requirements
- ✅ File exists and is non-empty
- ✅ Contains keywords: "requirements", "functional", or "problem"

### Phase 2: Architecture ADRs
- ✅ File exists and is non-empty
- ✅ Contains keywords: "architecture", "decision", or "ADR"

### Phase 3: Implementation
- ✅ `app.py` exists and is non-empty
- ✅ Contains Flask code: "Flask" or "@app.route"
- ✅ `requirements.txt` exists (warning if missing)

### Phase 4: Testing
- ✅ `test_app.py` exists and is non-empty
- ✅ Contains test functions: "def test_" or "import pytest"

### Phase 5: Deployment
- ✅ `deploy-local.sh` exists and is executable
- ✅ `test-endpoints.sh` exists (warning if missing)

## Retry Behavior

When a phase fails:

1. **Attempt 1**: Initial generation
2. **Wait**: 2 seconds
3. **Attempt 2**: Retry with same prompt
4. **Wait**: 4 seconds
5. **Attempt 3**: Final retry
6. **Failure**: Exit with error if all attempts fail

Example output:
```
⚠️  WARNING: Business Requirements generation failed (attempt 1/3)
⏳ Retrying in 2 seconds...
⚠️  WARNING: Business Requirements generation failed (attempt 2/3)
⏳ Retrying in 4 seconds...
✅ Business Requirements generated successfully (attempt 3/3)
```

## Error Messages

The system provides clear, color-coded feedback:

- 🔴 **Red errors**: Critical failures requiring attention
- 🟡 **Yellow warnings**: Non-critical issues (e.g., missing optional files)
- 🟢 **Green success**: Validation passed

## File Validation

Each generated file is checked:

```bash
# File must exist
[ -f "output/requirements.md" ] || fail

# File must not be empty
[ -s "output/requirements.md" ] || fail

# File must contain expected content
grep -q "requirements" "output/requirements.md" || fail
```

## Command Retry

Even simple commands like `head` and `ls` are wrapped with retry logic:

```bash
# This will retry if app.py doesn't exist yet
head -50 output/service/app.py

# The system will:
# 1. Try command
# 2. If fails (file not found), retry after delay
# 3. Repeat up to MAX_RETRIES times
# 4. Show clear error if all fail
```

## Debug Mode

Combine with `--debug` for detailed retry information:

```bash
./demo.sh --debug --max-retries 5
```

This shows:
- Attempt numbers
- Wait times
- Validation checks
- Error details
- Bash command traces

## Fallback to Simulation

If GitHub Copilot is unavailable:
- System detects missing CLI
- Automatically falls back to simulation mode
- Generates realistic placeholder content
- Continues without failures

This ensures demos work even without live AI:

```bash
[DEBUG] Copilot CLI not found
[DEBUG] Using simulation mode
✅ Business Requirements generated successfully (attempt 1/3)
```

## Best Practices

### For Presentations

```bash
# Ensure reliability with 5 retries
./demo.sh --max-retries 5

# Test in non-interactive mode first
NO_WAIT=true ./demo.sh --max-retries 3
```

### For CI/CD

```bash
# High retry count for flaky environments
./run-demo-auto.sh --max-retries 10

# Check exit code
if [ $? -eq 0 ]; then
    echo "Demo passed"
else
    echo "Demo failed after all retries"
    exit 1
fi
```

### For Development

```bash
# Quick iterations with fewer retries
./demo.sh --max-retries 1 --debug
```

## Troubleshooting

### Phase Keeps Failing

If a phase consistently fails after 3 attempts:

1. **Check AI service**: Is GitHub Copilot running?
2. **Check prompts**: Are prompt files readable?
3. **Check disk space**: Can files be written?
4. **Check logs**: Look at `output/*.log` files
5. **Try debug mode**: `./demo.sh --debug`

### Validation Too Strict

If validation rejects valid output:

1. Check the validation function in `demo.sh`
2. The validation might need adjustment for your content
3. Look for validation functions: `validate_requirements()`, etc.

### Slow Retries

If retries take too long:

1. Reduce retry count: `--max-retries 2`
2. Check network latency to AI service
3. Use simulation mode for testing: Set `HAS_COPILOT=false`

## Implementation Details

### Core Functions

```bash
# Generic retry wrapper
retry_command() {
    local max_retries=$1
    shift
    # Run command with retries and exponential backoff
}

# File validation
validate_file() {
    local file=$1
    local description=$2
    # Check existence and non-empty
}

# Generation with validation
generate_with_retry() {
    local phase_name=$1
    local prompt_file=$2
    local output_file=$3
    local validation_func=$4
    # Generate, validate, retry if needed
}
```

### Phase-Specific Validators

Each phase has a custom validator:

- `validate_requirements()`: Check requirements content
- `validate_architecture()`: Check ADR structure
- `validate_implementation()`: Check Flask code
- `validate_testing()`: Check pytest files
- `validate_deployment()`: Check deployment scripts

## Future Improvements

Potential enhancements:

- [ ] Configurable validation rules via config file
- [ ] More sophisticated content analysis (AST parsing for Python)
- [ ] Retry with modified prompts (add "please fix" context)
- [ ] Parallel retry strategies (try multiple variations)
- [ ] Machine learning from successful patterns
- [ ] Integration with error tracking systems

## Related Documentation

- [DEBUG_MODE.md](DEBUG_MODE.md) - Debugging guide
- [NON_INTERACTIVE_MODE.md](NON_INTERACTIVE_MODE.md) - Automation guide
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues
- [DEMO_FLOW.md](DEMO_FLOW.md) - Pipeline overview
