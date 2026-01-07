# Troubleshooting Guide

## Common Issues and Solutions

### 1. copilot Authentication Issues

**Symptom:** "authentication required" or "not authenticated" from copilot

**Solutions:**
```bash
# Check if authenticated
gh auth status

# Login to GitHub
gh auth login

# Check copilot extension
gh extension list | grep copilot

# Install if missing
gh extension install github/gh-copilot

# Or use simulated mode (no auth needed)
# Demo automatically falls back to simulation
```

### 2. LocalStack Won't Start

**Symptom:** `docker-compose up -d` fails or hangs

**Solutions:**
```bash
# Check if port 4566 is already in use
lsof -ti:4566 | xargs kill -9

# Remove old containers
docker-compose down -v

# Restart Docker Desktop
# macOS: Click Docker icon → Restart

# Try starting again
docker-compose up -d

# Check logs
docker-compose logs -f
```

### 2. Docker Out of Memory

**Symptom:** LocalStack crashes or demo is slow

**Solutions:**
```bash
# macOS: Docker Desktop → Settings → Resources
# Increase memory to at least 4GB

# Check current allocation
docker info | grep -i memory

# Restart Docker after changes
```

### 3. Port Conflicts

**Symptom:** "address already in use"

**Solutions:**
```bash
# Find what's using port 4566
lsof -i :4566

# Find what's using port 5000 (Flask)
lsof -i :5000

# Kill the process
kill -9 <PID>

# Or use different ports in docker-compose.yml
```

### 4. Demo Script Hangs

**Symptom:** Script stops responding

**Solutions:**
```bash
# Force quit with Ctrl+C

# Clean up processes
pkill -f 'python.*app.py'
pkill -f demo.sh

# Restart LocalStack
cd localstack
docker-compose restart
cd ..

# Run again
./run-demo.sh
```

### 5. Python Dependencies Fail

**Symptom:** "pip install" errors

**Solutions:**
```bash
# Ensure Python 3 is active
python3 --version

# Use virtual environment
python3 -m venv venv
source venv/bin/activate

# Update pip
pip install --upgrade pip

# Install dependencies
cd output/service
pip install -r requirements.txt
```

### 6. awslocal Command Not Found

**Symptom:** "awslocal: command not found"

**Solutions:**
```bash
# Install awscli-local
pip install awscli-local

# Or use aws with endpoint
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### 7. DynamoDB Table Already Exists

**Symptom:** "ResourceInUseException: Table already exists"

**Solutions:**
```bash
# Delete the table
awslocal dynamodb delete-table --table-name tasks

# Or use different table name
export TABLE_NAME=tasks-demo-2
```

### 8. Flask App Won't Start

**Symptom:** "Address already in use" on port 5000

**Solutions:**
```bash
# Kill existing Flask process
pkill -f 'python.*app.py'

# Or use different port
export FLASK_PORT=5001
python app.py
```

### 9. Demo-Magic Not Working

**Symptom:** Script doesn't show simulated typing

**Solutions:**
```bash
# Check if demo-magic.sh exists
ls -l demo-magic.sh

# Re-download if needed
curl -L https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh > demo-magic.sh
chmod +x demo-magic.sh

# Check it sources correctly
source ./demo-magic.sh
echo $TYPE_SPEED
```

### 10. Simulated AI Responses Not Generated

**Symptom:** Output files are empty

**Solutions:**
```bash
# Check the simulate_ai_response function in demo.sh
# Make sure case statements match prompt filenames

# Run manually to test
bash -c "source demo.sh && simulate_ai_response prompts/01-concept.txt output/test.md"

# Check output
cat output/test.md
```

## Quick Reset Procedure

If everything is broken, start fresh:

```bash
cd /Volumes/dev/git/conferences/dev.bg/2026-01-07/live-demo

# 1. Kill all processes
pkill -f demo.sh
pkill -f 'python.*app.py'

# 2. Stop and remove containers
cd localstack
docker-compose down -v
docker system prune -f

# 3. Clear output
cd ..
rm -rf output/*
mkdir -p output/service/tests

# 4. Restart LocalStack
cd localstack
docker-compose up -d
sleep 10

# 5. Verify health
curl http://localhost:4566/_localstack/health

# 6. Try demo again
cd ..
./run-demo.sh
```

## Performance Tips

### Speed Up Demo for Testing

Edit `demo.sh`:
```bash
# Change TYPE_SPEED for faster typing
TYPE_SPEED=10  # Default is 40

# Skip waits in testing
NO_WAIT=true ./demo.sh
```

### Reduce LocalStack Startup Time

```bash
# Keep LocalStack running between demos
# Don't run docker-compose down

# Just clean up data
awslocal dynamodb delete-table --table-name tasks
```

### Pre-generate Outputs

For backup or faster demo:
```bash
# Run once to generate all outputs
./demo.sh

# Save outputs
cp -r output output-backup

# During presentation, if something fails:
cp -r output-backup/* output/
```

## Debug Mode

Enable debug output:

```bash
# In demo.sh, add at the top:
set -x  # Print commands as they execute
set -e  # Exit on error

# Run with debug
bash -x ./demo.sh
```

## Health Checks

Before starting demo:

```bash
# Run test script
./test-setup.sh

# Should see all ✅ marks

# Check Docker
docker ps

# Check LocalStack
curl http://localhost:4566/_localstack/health | jq .

# Check disk space
df -h

# Check available memory
# macOS:
vm_stat | head -n 5

# Linux:
free -h
```

## Emergency Presentation Mode

If demo fails during presentation:

### Option 1: Show Pre-recorded
```bash
# Use asciinema to record demo beforehand
asciinema rec demo.cast

# Play during presentation
asciinema play demo.cast
```

### Option 2: Show Screenshots
```bash
# Take screenshots of each phase
# Keep in presentation/screenshots/
```

### Option 3: Walk Through Code
```bash
# Show the generated output files directly
cd output
ls -R
cat service/app.py
cat requirements.md
```

## Getting Help

1. Check [README.md](../README.md) for complete documentation
2. Review [DEMO_FLOW.md](DEMO_FLOW.md) for expected behavior
3. Check Docker logs: `docker-compose logs`
4. Check LocalStack status: `curl http://localhost:4566/_localstack/health`
5. Test individual components with `test-setup.sh`

## Contact Info for Issues

If you find bugs or have improvements:
- Check Docker version: `docker --version`
- Check Python version: `python3 --version`
- Check LocalStack version: `docker exec demo-localstack localstack --version`
- Document steps to reproduce
- Save logs: `docker-compose logs > localstack.log`

## Known Limitations

1. **Cursor CLI** - Demo simulates responses (not real AI)
2. **Network** - Need internet for initial Docker image download
3. **macOS** - Some volume mount paths may need adjustment
4. **Memory** - Requires 4GB+ allocated to Docker
5. **Timing** - May need adjustment based on system speed

## Success Checklist

Before presentation:

- [ ] Docker Desktop running
- [ ] 4GB+ memory allocated to Docker
- [ ] Port 4566 and 5000 available
- [ ] Ran `./test-setup.sh` successfully
- [ ] Ran full demo at least once
- [ ] Saved backup of generated outputs
- [ ] Tested on presentation computer
- [ ] Have backup plan (screenshots/recording)
- [ ] Know how to reset quickly (Ctrl+C → restart)

You're ready! 🚀
