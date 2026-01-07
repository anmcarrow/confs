# Non-Interactive Mode Guide

## Overview

The demo supports fully automated, non-interactive execution for testing, CI/CD, and batch runs.

## Quick Start

### Method 1: Using run-demo-auto.sh (Recommended)

```bash
cd live-demo
./run-demo-auto.sh
```

This runs the entire demo without any pauses or user input.

### Method 2: Using Environment Variables

```bash
cd live-demo
NO_WAIT=true TYPE_SPEED=0 ./demo.sh
```

### Method 3: Fast but with typing animation

```bash
cd live-demo
NO_WAIT=true TYPE_SPEED=10 ./demo.sh
```

## Environment Variables

### NO_WAIT
Controls whether the demo pauses for user input.

- `NO_WAIT=false` (default) - Interactive mode, press ENTER to continue
- `NO_WAIT=true` - Non-interactive mode, no pauses

### TYPE_SPEED
Controls the simulated typing speed.

- `TYPE_SPEED=0` - Instant display, no animation
- `TYPE_SPEED=10` - Fast typing
- `TYPE_SPEED=20` - Default typing speed
- `TYPE_SPEED=40` - Slow, realistic typing
- `TYPE_SPEED=100` - Very slow

## Use Cases

### 1. Automated Testing in CI/CD

```yaml
# GitHub Actions example
- name: Run Demo
  run: |
    cd live-demo
    ./run-demo-auto.sh
```

### 2. Quick Development Testing

```bash
# Test your changes quickly
NO_WAIT=true TYPE_SPEED=0 ./demo.sh
```

### 3. Batch Execution

```bash
# Run demo multiple times
for i in {1..5}; do
  echo "Run $i"
  NO_WAIT=true TYPE_SPEED=0 ./demo.sh
  rm -rf output/*
done
```

### 4. Timed Execution

```bash
# Measure execution time
time NO_WAIT=true TYPE_SPEED=0 ./demo.sh
```

### 5. Logging Output

```bash
# Capture all output to log file
NO_WAIT=true TYPE_SPEED=0 ./demo.sh 2>&1 | tee demo-run.log
```

## Comparison: Interactive vs Non-Interactive

| Feature | Interactive | Non-Interactive |
|---------|-------------|-----------------|
| User Input | Required (press ENTER) | Not required |
| Typing Animation | Yes (configurable) | Optional |
| Execution Time | ~15 minutes | ~2-3 minutes |
| Best For | Presentations | Testing/CI/CD |
| Demo Control | Manual pacing | Automatic |

## Tips for Non-Interactive Mode

### 1. Ensure LocalStack is Running

```bash
# Start LocalStack first
cd localstack && docker-compose up -d && cd ..

# Then run demo
./run-demo-auto.sh
```

### 2. Clean Output Between Runs

```bash
# Clean previous outputs
rm -rf output/*

# Run demo
./run-demo-auto.sh
```

### 3. Capture Errors

```bash
# Run with error capture
NO_WAIT=true TYPE_SPEED=0 ./demo.sh 2>&1 | tee -a demo-errors.log
```

### 4. Background Execution

```bash
# Run in background (not recommended for demo)
nohup ./run-demo-auto.sh > demo.log 2>&1 &
```

## Troubleshooting

### Demo Hangs in Non-Interactive Mode

Check if `NO_WAIT` is properly exported:

```bash
# Debug mode
set -x
NO_WAIT=true TYPE_SPEED=0 ./demo.sh
```

### Commands Execute Too Fast

Increase TYPE_SPEED:

```bash
NO_WAIT=true TYPE_SPEED=20 ./demo.sh
```

### Missing pv Command

The typing animation requires `pv`:

```bash
# macOS
brew install pv

# Ubuntu/Debian
sudo apt-get install pv

# Or disable animation
TYPE_SPEED=0 ./demo.sh
```

## Advanced Usage

### Selective Phase Execution

You can modify demo.sh to skip phases:

```bash
# Set environment variable to skip phases
SKIP_PHASE_1=true NO_WAIT=true ./demo.sh
```

### Custom Timing

Create your own runner with custom delays:

```bash
#!/bin/bash
export NO_WAIT=true
export TYPE_SPEED=15

# Add custom logic between phases
./demo.sh
```

### Integration with Other Tools

#### With Docker Compose

```bash
# Run LocalStack and demo together
docker-compose -f localstack/docker-compose.yml up -d
sleep 10
NO_WAIT=true TYPE_SPEED=0 ./demo.sh
docker-compose -f localstack/docker-compose.yml down
```

#### With Make

```makefile
.PHONY: demo-auto
demo-auto:
	cd live-demo && ./run-demo-auto.sh

.PHONY: demo-fast
demo-fast:
	cd live-demo && NO_WAIT=true TYPE_SPEED=0 ./demo.sh
```

## Performance Metrics

Typical execution times:

| Mode | Duration |
|------|----------|
| Interactive (TYPE_SPEED=40) | ~15 min |
| Non-Interactive (TYPE_SPEED=0) | ~2-3 min |
| Non-Interactive (TYPE_SPEED=10) | ~4-5 min |

*Times vary based on system performance and copilot response time*

## CI/CD Integration Examples

### GitHub Actions

```yaml
name: Demo Test
on: [push]
jobs:
  test-demo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Start LocalStack
        run: |
          cd live-demo/localstack
          docker-compose up -d
          sleep 15
      - name: Run Demo
        run: |
          cd live-demo
          ./run-demo-auto.sh
      - name: Verify Output
        run: |
          test -f live-demo/output/requirements.md
          test -f live-demo/output/architecture.md
```

### GitLab CI

```yaml
demo-test:
  script:
    - cd live-demo
    - ./run-demo-auto.sh
  artifacts:
    paths:
      - live-demo/output/
```

### Jenkins

```groovy
stage('Demo Test') {
    steps {
        sh 'cd live-demo && ./run-demo-auto.sh'
    }
}
```

## Summary

**For Presentations:**
```bash
./run-demo.sh  # Choose option 1
```

**For Testing:**
```bash
./run-demo-auto.sh
```

**For CI/CD:**
```bash
NO_WAIT=true TYPE_SPEED=0 ./demo.sh
```

**For Development:**
```bash
NO_WAIT=true TYPE_SPEED=10 ./demo.sh
```

---

The non-interactive mode gives you full flexibility to run the demo in any environment without manual intervention! 🚀
