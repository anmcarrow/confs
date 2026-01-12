# AI-Driven Development Pipeline Demo

Complete demo setup for showcasing AI-driven software development from concept to deployment. Basically – just a practical joke aroud "AI almighty". Was created with Copilot + Claude Sonnet LLM. And, boy oh boy, damn thing clearly cheated in process.

All this demo required pre-installde `copilot` CLI agent as well as Docker/Podman before the run.

## Additilonal materials
- [Another good presentation](https://www.youtube.com/watch?v=J5Z_yFVjilk) about the practical state of AI-driven development

## Quick Start

Run the demo with a single command:

```bash
cd live-demo
./run-demo.sh
```

[![asciicast](https://asciinema.org/a/Dw6F7YWmqTmMDHUaOpWqDm0Qt.svg)](https://asciinema.org/a/Dw6F7YWmqTmMDHUaOpWqDm0Qt)

## Key Features

✅ **Fully Automated** - From concept to deployment without manual coding
✅ **AI-Powered** - Uses GitHub Copilot CLI for real AI generation
✅ **Reliable** - Automatic retry logic with validation (3 attempts per phase)
✅ **Flexible** - Interactive, non-interactive, and debug modes
✅ **Local AWS** - Deploys to LocalStack for safe testing

## What This Demo Does

1. **Business Concept** - AI generates requirements from a business idea
2. **Architecture Design** - AI creates Architecture Decision Records (ADRs)
3. **Implementation** - AI generates complete Flask REST API code
4. **Testing** - AI creates comprehensive test suite
5. **Deployment** - Deploys to LocalStack (local AWS environment)

## Directory Structure

```
live-demo/
├── run-demo.sh           # Main launcher script (START HERE)
├── run-demo-auto.sh      # Non-interactive runner (no pauses)
├── demo.sh               # Demo orchestration script
├── lib/                  # Sourced libraries
│   ├── demo-magic.sh     # Terminal presentation framework
│   └── visualizations.sh # Charts and visual effects
├── tests/                # Test scripts
│   ├── test-copilot.sh   # Copilot integration test
│   ├── test-reliability.sh # Reliability validation test
│   └── test-setup.sh     # Setup verification test
├── docs/                 # Documentation
├── prompts/              # AI prompts for each phase
│   ├── 01-concept.txt
│   ├── 02-architecture.txt
│   ├── 03-implementation.txt
│   ├── 04-testing.txt
│   └── 05-deployment.txt
├── localstack/           # LocalStack configuration
│   ├── docker-compose.yml
│   └── init-aws.sh
└── output/               # Generated files go here
```

## Prerequisites

- Docker & docker-compose
- Python 3.x
- curl
- jq (optional, for pretty JSON)

The launcher script will check all prerequisites automatically.

## Demo Features

- **Simulated typing** - Looks like live coding
- **Step-by-step progression** - Press ENTER to advance
- **Color-coded phases** - Easy to follow visually
- **Live execution** - Real code generation and deployment
- **LocalStack integration** - No AWS account needed
- **Non-interactive mode** - Run without any pauses (3-5s random auto-waits)
- **Debug mode** - Bash trace for deep troubleshooting
- **Verbose mode** - Command output without bash trace overhead
- **Visual analytics** - Colorful charts after each phase (5-7s displays)
- **🎨 NEW: Horizontal timeline** - Track progress across all 5 phases
- **🎨 NEW: Phase badges** - Eye-catching phase transition markers
- **🎨 NEW: Animated spinners** - Dynamic loading during AI generation
- **🎨 NEW: Live code streaming** - Syntax-highlighted code reveal

## Debug Mode

Enable bash trace (`set -x`) for deep troubleshooting:

### With Any Script
```bash
# Interactive demo with debug
./run-demo.sh --debug

# Non-interactive with debug
./run-demo-auto.sh --debug

# Direct execution with debug
./demo.sh --debug

# Test script with debug
./test-copilot.sh --debug
```

### What Debug Mode Shows
- ✅ Full bash trace (`set -x`)
- ✅ Every command execution
- ✅ Variable expansions
- ✅ Function calls
- ✅ Exit codes

## Verbose Mode

Show command execution output without bash trace overhead:

### With Any Script
```bash
# Interactive demo with verbose
./run-demo.sh --verbose

# Non-interactive with verbose
./run-demo-auto.sh --verbose

# Direct execution with verbose
./demo.sh --verbose

# Combined with other flags
./demo.sh --verbose --max-retries 5
```

### What Verbose Mode Shows
- ✅ Command execution details
- ✅ AI generation output (real-time with `tee`)
- ✅ Validation progress
- ✅ Auto-wait timing in non-interactive mode
- ✅ Phase execution details
- ❌ No bash trace (cleaner than debug)

### Use Cases
- **Presentations**: Show what's happening transparently
- **Development**: Understand flow without trace noise
- **CI/CD**: Detailed logs without overwhelming output
- **Learning**: See how demo works step-by-step

See [docs/VERBOSE_MODE.md](docs/VERBOSE_MODE.md) for complete guide.

## Non-Interactive Mode

For automated testing, CI/CD pipelines, or quick validation. Now includes random 3-5 second auto-waits instead of manual `read` prompts.

### Quick Run
```bash
./run-demo-auto.sh
```

### With Verbose Output
```bash
# See auto-wait timing and command output
./run-demo-auto.sh --verbose

# Shows: [AUTO-WAIT: 3s], [AUTO-WAIT: 4s], etc.
```

### With Environment Variables
```bash
# Fast execution, no typing animation, auto-waits
NO_WAIT=true TYPE_SPEED=0 ./demo.sh

# Slow execution but automated
NO_WAIT=true TYPE_SPEED=20 ./demo.sh
```

### Auto-Wait Behavior
- **Random delays**: 3-5 seconds between phases
- **No manual input**: Fully automated
- **Visible in verbose mode**: `[AUTO-WAIT: Xs]` messages
- **Mimics human interaction**: Natural pacing for presentations

### Use Cases
- **Automated Testing**: Validate demo works in CI/CD
- **Quick Development**: Test changes without waiting for animations
- **Batch Execution**: Run multiple times for stress testing
- **Recording**: Create consistent recordings for documentation
- **Unattended Demos**: Let it run without interaction

### Environment Variables
- `NO_WAIT=true` - Skip all pauses, no user input required
- `TYPE_SPEED=0` - Disable typing animation (instant display)
- `TYPE_SPEED=20` - Default typing speed (adjust 0-100)

## Usage Options

### Option 1: Full Automated Demo (Recommended)
```bash
./run-demo.sh
# Choose option 1
# Uses copilot for real AI generation
```

### Option 2: Step-by-Step Interactive
```bash
./run-demo.sh
# Choose option 2
```

### Option 3: Non-Interactive Mode (Fully Automated)
```bash
./run-demo-auto.sh
# Runs without any pauses or user input
# Perfect for automated testing or CI/CD
```

### Option 4: Direct Environment Variables
```bash
# Set environment variables for non-interactive mode
NO_WAIT=true TYPE_SPEED=0 ./demo.sh

# With debug enabled
NO_WAIT=true TYPE_SPEED=0 ./demo.sh --debug

# With verbose mode (see auto-wait timing)
NO_WAIT=true TYPE_SPEED=0 ./demo.sh --verbose

# With custom retry count
./demo.sh --max-retries 5

# Combined options
./demo.sh --verbose --max-retries 5
```

## Reliability Features

The demo includes automatic retry logic and validation:

### Automatic Retries
- **Default**: 3 attempts per phase
- **Configurable**: Use `--max-retries N`
- **Smart validation**: Phase-specific checks
- **Exponential backoff**: 2^attempt seconds delay

### Validation
Each phase validates:
- ✅ Files exist and are non-empty
- ✅ Content contains expected keywords
- ✅ Code structure is valid (Flask routes, test functions, etc.)

### Error Recovery
If generation fails:
1. Shows clear error message
2. Waits with exponential backoff
3. Retries with same prompt
4. Continues up to MAX_RETRIES
5. Exits with error if all attempts fail

See [docs/RELIABILITY.md](docs/RELIABILITY.md) for details.

### Option 5: Manual Control
```bash
# Start LocalStack
cd localstack && docker-compose up -d

# Run phases individually
cd ..
cat prompts/01-concept.txt
# ... manual execution
```

## Customization

Edit prompt files in `prompts/` to change what gets generated:
- `01-concept.txt` - Business requirements
- `02-architecture.txt` - Architecture decisions
- `03-implementation.txt` - Code generation instructions
- `04-testing.txt` - Test generation
- `05-deployment.txt` - Deployment configuration

## Troubleshooting

### Enable Debug Mode First
```bash
# Run with debug to see detailed execution
./run-demo.sh --debug
# or
./run-demo-auto.sh --debug
```

### Docker not running
```bash
# Start Docker Desktop (macOS) or Docker daemon (Linux)
```

### Port 4566 already in use
```bash
# Find and stop the process using port 4566
lsof -ti:4566 | xargs kill -9
```

### LocalStack not starting
```bash
# Check Docker logs
cd localstack
docker-compose logs -f
```

### Demo script fails
```bash
# Enable debug mode to see what's happening
./demo.sh --debug

# If generation consistently fails, try more retries
./demo.sh --max-retries 5

# Clean up and restart
cd localstack && docker-compose down -v
cd .. && rm -rf output/*
./run-demo.sh
```

### Files not generated
The demo now includes automatic retry logic. If files aren't generated after 3 attempts:

1. Check if GitHub Copilot CLI is working: `./tests/test-copilot.sh`
2. Try debug mode: `./demo.sh --debug`
3. Increase retries: `./demo.sh --max-retries 10`
4. Check validation in [RELIABILITY.md](RELIABILITY.md)

## Cleanup

Stop everything:
```bash
cd localstack
docker-compose down -v
cd ..
pkill -f 'python.*app.py'
```

## Notes for Presenters

1. **Test before presenting** - Run through the demo at least once
2. **Check Docker memory** - Allocate 4GB+ to Docker
3. **Have backup** - Save generated output from a successful run
4. **Network requirement** - Need internet for downloading LocalStack image
5. **Timing** - Full demo takes ~10-15 minutes

## What Gets Generated

- `output/requirements.md` - Requirements document
- `output/architecture.md` - ADR document
- `output/service/app.py` - Flask REST API
- `output/service/requirements.txt` - Python dependencies
- `output/service/tests/test_app.py` - Test suite
- `output/service/deploy-local.sh` - Deployment script
- `output/service/test-endpoints.sh` - API testing script

## Documentation

📖 **See [docs/INDEX.md](docs/INDEX.md) for complete documentation index**

### Quick Links

- [README.md](README.md) - This file (main documentation)
- [docs/SETUP_COMPLETE.md](docs/SETUP_COMPLETE.md) - Quick start guide
- [docs/DEMO_FLOW.md](docs/DEMO_FLOW.md) - Visual pipeline diagram
- [docs/COPILOT_INTEGRATION.md](docs/COPILOT_INTEGRATION.md) - AI tool setup
- [docs/NON_INTERACTIVE_MODE.md](docs/NON_INTERACTIVE_MODE.md) - Automation guide
- [docs/DEBUG_MODE.md](docs/DEBUG_MODE.md) - Debugging guide
- [docs/VERBOSE_MODE.md](docs/VERBOSE_MODE.md) - **Verbose output without bash trace**
- [docs/RELIABILITY.md](docs/RELIABILITY.md) - Retry logic and validation
- [docs/LOCALSTACK_JSON_VISIBILITY.md](docs/LOCALSTACK_JSON_VISIBILITY.md) - **JSON API responses**
- [docs/VISUALIZATIONS.md](docs/VISUALIZATIONS.md) - **Colorful charts and metrics**
- [docs/VISUAL_ENHANCEMENTS.md](docs/VISUAL_ENHANCEMENTS.md) - **🎨 NEW: Timeline, spinners, code streaming**
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues

## Technologies Demonstrated

- **AI**: GitHub Copilot CLI (with simulation fallback)
- **Backend**: Python, Flask
- **Database**: DynamoDB (via LocalStack)
- **Infrastructure**: AWS Lambda, API Gateway (simulated)
- **Testing**: pytest, moto
- **DevOps**: Docker, LocalStack
- **Reliability**: Automatic retries, validation, error recovery

## License

Demo materials for DevOps meetup presentation.
