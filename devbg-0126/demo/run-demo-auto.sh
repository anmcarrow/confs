#!/bin/bash

########################
# Non-Interactive Demo Runner
# Runs the full demo without any pauses
# Usage: ./run-demo-auto.sh [--debug] [--max-retries N]
########################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Parse arguments
DEBUG_FLAG=""
VERBOSE_FLAG=""
MAX_RETRIES_FLAG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG_FLAG="--debug"
            echo "Debug mode enabled"
            shift
            ;;
        --verbose)
            VERBOSE_FLAG="--verbose"
            echo "Verbose mode enabled"
            shift
            ;;
        --max-retries)
            MAX_RETRIES_FLAG="--max-retries $2"
            echo "Max retries set to: $2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: ./run-demo-auto.sh [--debug] [--verbose] [--max-retries N]"
            exit 1
            ;;
    esac
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║     AI-DRIVEN DEVELOPMENT PIPELINE                         ║"
echo "║     Non-Interactive Mode                                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Export non-interactive settings
export NO_WAIT=true
export TYPE_SPEED=0

echo "🚀 Starting non-interactive demo..."
echo "   (Demo will run with automatic 3-5 second pauses)"
echo ""
sleep 2

# Run the demo script with all flags
./demo.sh $DEBUG_FLAG $VERBOSE_FLAG $MAX_RETRIES_FLAG

echo ""
echo "✅ Non-interactive demo complete!"
