# Quick Reference: Reliability Features

## Commands

```bash
# Run with default 3 retries
./demo.sh

# Custom retry count
./demo.sh --max-retries 5

# With debug mode
./demo.sh --debug --max-retries 5

# Non-interactive with retries
./run-demo-auto.sh --max-retries 10

# Test reliability features
./test-reliability.sh
```

## Validation Checklist

### ✅ Phase 1: Requirements
- File exists and non-empty
- Contains: "requirements" OR "functional" OR "problem"

### ✅ Phase 2: Architecture
- File exists and non-empty
- Contains: "architecture" OR "decision" OR "ADR"

### ✅ Phase 3: Implementation
- `app.py` exists, non-empty, contains "Flask" OR "@app.route"
- `requirements.txt` exists (⚠️ warning if missing)

### ✅ Phase 4: Testing
- `test_app.py` exists, non-empty
- Contains: "def test_" OR "import pytest"

### ✅ Phase 5: Deployment
- `deploy-local.sh` exists and is executable
- `test-endpoints.sh` exists (⚠️ warning if missing)

## Error Messages

🔴 **Red** = Critical error, will retry
🟡 **Yellow** = Warning, non-critical
🟢 **Green** = Success

## Retry Behavior

| Attempt | Wait Time | Example |
|---------|-----------|---------|
| 1       | 0s        | Initial try |
| 2       | 2s        | 1st retry |
| 3       | 4s        | 2nd retry |
| 4       | 8s        | 3rd retry |

Formula: `wait_time = 2^attempt` seconds

## Exit Codes

- `0` = Success (all phases passed)
- `1` = Failure (phase failed after MAX_RETRIES)

## Testing

```bash
# Quick validation test
./test-reliability.sh

# Should see:
✅ All Reliability Tests Passed!
```

## Troubleshooting

### Phase keeps failing?
1. Try more retries: `--max-retries 10`
2. Enable debug: `--debug`
3. Check AI service: `./test-copilot.sh`

### Validation too strict?
Edit validators in `demo.sh`:
- `validate_requirements()`
- `validate_architecture()`
- `validate_implementation()`
- `validate_testing()`
- `validate_deployment()`

## Files

| File | Purpose |
|------|---------|
| `demo.sh` | Main script with retry logic |
| `test-reliability.sh` | Test suite |
| `RELIABILITY.md` | Full documentation |
| `IMPLEMENTATION_SUMMARY.md` | Technical details |

## Example Output

```
📋 PHASE 1: Business Concept & Requirements
# Sending to AI agent for requirements analysis...
⚠️  WARNING: Business Requirements generation failed (attempt 1/3)
⏳ Retrying in 2 seconds...
⚠️  WARNING: Business Requirements generation failed (attempt 2/3)
⏳ Retrying in 4 seconds...
✅ Business Requirements generated successfully (attempt 3/3)
```

## Best Practices

### For Presentations
```bash
./demo.sh --max-retries 5
```

### For CI/CD
```bash
./run-demo-auto.sh --max-retries 10
```

### For Development
```bash
./demo.sh --debug --max-retries 2
```

## Quick Debug

```bash
# Check syntax
bash -n demo.sh

# Test validators
./test-reliability.sh

# Test copilot
./test-copilot.sh

# Full debug run
NO_WAIT=true ./demo.sh --debug --max-retries 2
```
