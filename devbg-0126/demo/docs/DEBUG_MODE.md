# Debug Mode Guide

## Overview

All demo scripts support `--debug` flag for verbose logging and troubleshooting.

## Usage

### Basic Debug Mode

```bash
# Interactive demo with debug
./run-demo.sh --debug

# Non-interactive demo with debug
./run-demo-auto.sh --debug

# Direct execution with debug
./demo.sh --debug

# Test script with debug
./test-copilot.sh --debug
```

### Combined with Environment Variables

```bash
# Non-interactive + debug
NO_WAIT=true TYPE_SPEED=0 ./demo.sh --debug

# Fast execution + debug
NO_WAIT=true TYPE_SPEED=10 ./demo.sh --debug
```

## What Debug Mode Shows

When `--debug` is enabled, you'll see:

### 1. Bash Execution Traces
```
+ command -v copilot
+ echo 'copilot found at: /path/to/copilot'
+ pe 'cat prompts/01-concept.txt | copilot --allow-all-tools'
```

### 2. Debug Log Messages
```
[DEBUG] Checking for copilot CLI...
[DEBUG] copilot found at: /Users/am/.../copilot
[DEBUG] Simulating AI response for: prompts/01-concept.txt -> output/requirements.md
```

### 3. Function Entry/Exit
- Every function call is traced
- Variable assignments shown
- Return codes displayed

### 4. File Operations
- File reads and writes
- Directory changes
- Path resolutions

### 5. Environment State
- Environment variables
- Working directory
- Script arguments

## Debug Output Example

```bash
$ ./run-demo-auto.sh --debug

Debug mode enabled

╔════════════════════════════════════════════════════════════╗
║     AI-DRIVEN DEVELOPMENT PIPELINE                         ║
║     Non-Interactive Mode                                   ║
╚════════════════════════════════════════════════════════════╝

+ export NO_WAIT=true
+ export TYPE_SPEED=0
+ echo '🚀 Starting non-interactive demo...'
🚀 Starting non-interactive demo...
+ ./demo.sh --debug
+ DEBUG_MODE=true
+ set -x
+ source ./demo-magic.sh
++ TYPE_SPEED=20
++ NO_WAIT=false
[DEBUG] Checking for copilot CLI...
+ command -v copilot
+ debug_log 'copilot found at: /Users/am/.../copilot'
[DEBUG] copilot found at: /Users/am/.../copilot
...
```

## Use Cases

### 1. Troubleshooting Script Failures

```bash
# When script fails, run with debug
./run-demo.sh --debug 2>&1 | tee debug.log

# Review debug.log to find the failure point
grep -i "error\|fail" debug.log
```

### 2. Understanding Execution Flow

```bash
# See exactly what happens during each phase
./demo.sh --debug 2>&1 | grep "\[DEBUG\]"
```

### 3. Verifying Environment

```bash
# Check if copilot is detected correctly
./test-copilot.sh --debug
```

### 4. CI/CD Debugging

```yaml
# GitHub Actions with debug
- name: Run Demo (Debug)
  run: |
    cd live-demo
    ./run-demo-auto.sh --debug
```

### 5. Development Testing

```bash
# Quick test with full visibility
NO_WAIT=true TYPE_SPEED=0 ./demo.sh --debug
```

## Capturing Debug Output

### To File
```bash
# Capture all output (stdout + stderr)
./run-demo.sh --debug 2>&1 | tee demo-debug.log

# Only stderr (debug messages)
./run-demo.sh --debug 2> debug.log
```

### Timestamped Output
```bash
# Add timestamps to debug output
./run-demo.sh --debug 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee debug-timed.log
```

### Filter Debug Messages
```bash
# Only show debug logs
./demo.sh --debug 2>&1 | grep "\[DEBUG\]"

# Exclude debug logs
./demo.sh --debug 2>&1 | grep -v "\[DEBUG\]"
```

## Debug Levels

### Level 1: Debug Flag Only
```bash
./demo.sh --debug
```
Shows:
- Debug log messages
- Bash execution traces
- Function calls

### Level 2: Debug + Verbose Environment
```bash
set -x
export DEBUG=1
./demo.sh --debug
```
Shows everything from Level 1 plus:
- All environment variables
- Subshell execution
- Command substitutions

### Level 3: Debug + Trace All
```bash
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x
./demo.sh --debug
```
Shows everything from Level 2 plus:
- Source file and line numbers
- Function names in trace
- Call stack information

## Common Debug Patterns

### Finding Where Script Stops

```bash
# Run with debug, watch where it stops
./demo.sh --debug 2>&1 | tail -50
```

### Checking Variable Values

Debug logs show key variables:
```
[DEBUG] HAS_COPILOT=true
[DEBUG] NO_WAIT=true
[DEBUG] TYPE_SPEED=0
```

### Verifying File Creation

```bash
# Watch file operations
./demo.sh --debug 2>&1 | grep -E "output/.*\.(md|py|sh)"
```

### Monitoring AI Calls

```bash
# Track copilot invocations
./demo.sh --debug 2>&1 | grep -E "copilot|simulate_ai_response"
```

## Debugging Specific Issues

### Issue: Copilot Not Detected

```bash
$ ./test-copilot.sh --debug
+ command -v copilot
[DEBUG] Checking for copilot CLI...
[DEBUG] copilot not found, will use simulation
```

**Solution**: Install copilot or check PATH

### Issue: LocalStack Not Ready

```bash
$ ./run-demo-auto.sh --debug 2>&1 | grep localstack
+ docker-compose -f localstack/docker-compose.yml up -d
+ curl -s http://localhost:4566/_localstack/health
```

**Solution**: Increase wait time or check Docker

### Issue: Output Files Not Created

```bash
$ ./demo.sh --debug 2>&1 | grep "output/"
[DEBUG] Simulating AI response for: prompts/01-concept.txt -> output/requirements.md
+ cat > output/requirements.md
```

**Solution**: Check permissions on output directory

### Issue: Demo Hangs

```bash
# See where it hangs
./demo.sh --debug &
PID=$!
sleep 60
ps -p $PID -o comm,args
```

## Performance Profiling with Debug

### Execution Time per Phase

```bash
# Time each phase
./demo.sh --debug 2>&1 | grep "PHASE" | ts -s '[%s]'
```

### Function Call Frequency

```bash
# Count function calls
./demo.sh --debug 2>&1 | grep -oP '(?<=: )\w+(?=\(\))' | sort | uniq -c
```

## Disabling Debug Output

Debug output goes to stderr. To suppress:

```bash
# Run without debug messages (but keep script logs)
./demo.sh --debug 2>/dev/null

# Redirect debug to file, keep output clean
./demo.sh --debug 2>debug.log
```

## Debug Best Practices

1. **Always use debug for first run** - Catch issues early
2. **Save debug logs** - Useful for comparing runs
3. **Filter output** - Use grep to focus on relevant info
4. **Combine with non-interactive** - `NO_WAIT=true ./demo.sh --debug`
5. **Check exit codes** - `echo $?` after script completes

## Debug Mode in CI/CD

### GitHub Actions
```yaml
- name: Run Demo with Debug
  run: |
    cd live-demo
    ./run-demo-auto.sh --debug 2>&1 | tee ${{ github.workspace }}/debug.log
  
- name: Upload Debug Logs
  if: failure()
  uses: actions/upload-artifact@v2
  with:
    name: debug-logs
    path: debug.log
```

### GitLab CI
```yaml
demo-debug:
  script:
    - cd live-demo
    - ./run-demo-auto.sh --debug 2>&1 | tee debug.log
  artifacts:
    when: on_failure
    paths:
      - debug.log
```

### Jenkins
```groovy
stage('Demo Debug') {
    steps {
        sh 'cd live-demo && ./run-demo-auto.sh --debug 2>&1 | tee debug.log'
    }
    post {
        failure {
            archiveArtifacts artifacts: 'debug.log'
        }
    }
}
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./run-demo.sh --debug` | Interactive with debug |
| `./run-demo-auto.sh --debug` | Non-interactive with debug |
| `./demo.sh --debug` | Direct execution with debug |
| `./test-copilot.sh --debug` | Test script with debug |
| `NO_WAIT=true ./demo.sh --debug` | Fast + debug |
| `./demo.sh --debug 2>&1 \| tee log` | Debug to file and console |
| `./demo.sh --debug 2>&1 \| grep DEBUG` | Only debug messages |

---

Debug mode makes it easy to understand what's happening and troubleshoot any issues! 🔍
