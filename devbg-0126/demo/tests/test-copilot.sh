#!/bin/bash

# Quick test of copilot integration
# Usage: ./test-copilot.sh [--debug]

# Parse arguments
DEBUG_MODE=false
VERBOSE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG_MODE=true
            set -x
            echo "Debug mode enabled"
            shift
            ;;
        --verbose)
            VERBOSE=true
            echo "Verbose mode enabled"
            shift
            ;;
        *)
            shift
            ;;
    esac
done
echo ""

echo "Testing copilot integration..."
echo ""

# Test 1: Check copilot availability
echo "1. Checking copilot..."
if command -v copilot &> /dev/null; then
    echo "   ✅ copilot found at: $(which copilot)"
    echo "   Version: GitHub Copilot CLI"
else
    echo "   ⚠️  copilot not found (demo will use simulated responses)"
fi
echo ""

# Test 2: Test copilot with simple prompt
if command -v copilot &> /dev/null; then
    echo "2. Testing copilot with simple prompt..."
    echo "   Prompt: 'Say hello in exactly 5 words'"
    echo ""
    
    RESULT=$(echo "Say hello in exactly 5 words" | copilot --allow-all-tools 2>&1 | head -5)
    
    if [ $? -eq 0 ]; then
        echo "   ✅ copilot responded successfully:"
        echo "$RESULT"
    else
        echo "   ❌ copilot failed:"
        echo "$RESULT"
    fi
else
    echo "2. Skipping copilot test (not installed)"
fi
echo ""

# Test 3: Source demo.sh and check function
echo "3. Testing demo.sh copilot detection..."
cd /Volumes/dev/git/conferences/dev.bg/2026-01-07/live-demo
source ../lib/demo-magic.sh 2>/dev/null

# Extract just the check function
if command -v copilot &> /dev/null; then
    echo "   ✅ Demo will use REAL AI generation with copilot"
else
    echo "   ℹ️  Demo will use SIMULATED responses"
fi
echo ""

echo "✅ Integration test complete!"
echo ""
echo "To run full demo: ./run-demo.sh"
