#!/bin/bash

########################
# Demo Launcher Script
# Single command to start the demo
# Usage: ./run-demo.sh [--debug] [--verbose]
########################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Parse arguments
DEBUG_FLAG=""
VERBOSE_FLAG=""
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
        *)
            shift
            ;;
    esac
done
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║     AI-DRIVEN DEVELOPMENT PIPELINE DEMO                    ║"
echo "║     Launcher Script                                        ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi
echo "✅ Docker found"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker."
    exit 1
fi
echo "✅ Docker is running"

# Check for docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose not found, trying 'docker compose'..."
    if ! docker compose version &> /dev/null; then
        echo "❌ docker-compose is not available."
        exit 1
    fi
    # Create alias for docker compose
    alias docker-compose='docker compose'
fi
echo "✅ docker-compose found"

# Check for curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed."
    exit 1
fi
echo "✅ curl found"

# Check for jq (optional but recommended)
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found (optional, for pretty JSON output)"
    echo "   Install with: brew install jq (macOS) or apt-get install jq (Linux)"
else
    echo "✅ jq found"
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed."
    exit 1
fi
echo "✅ Python 3 found"

# Check for pip
if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    echo "❌ pip is not installed."
    exit 1
fi
echo "✅ pip found"

echo ""
echo "✅ All prerequisites met!"
echo ""

# Clean up any previous runs
echo "🧹 Cleaning up previous demo runs..."
pkill -f 'python.*app.py' 2>/dev/null || true
cd localstack && docker-compose down -v 2>/dev/null || true
cd "$SCRIPT_DIR"
rm -rf output/service 2>/dev/null || true
rm -rf output/*.md output/*.log 2>/dev/null || true
mkdir -p output
echo "✅ Cleanup complete"
echo ""

# Start LocalStack first
echo "🐳 Starting LocalStack (this may take 30-60 seconds)..."
cd localstack
docker-compose up -d
cd "$SCRIPT_DIR"

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:4566/_localstack/health | grep -q "running"; then
        echo "✅ LocalStack is ready!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""
echo ""

# Ask user if they want to run the demo
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ready to start the demo!"
echo ""
echo "Options:"
echo "  1) Run full automated demo (recommended for presentation)"
echo "  2) Run step-by-step interactive demo"
echo "  3) Skip demo and just start LocalStack"
echo "  4) Exit"
echo ""
read -p "Choose option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Starting automated demo..."
        echo "   (Press ENTER to advance through each step)"
        echo ""
        sleep 2
        ./demo.sh $DEBUG_FLAG $VERBOSE_FLAG
        ;;
    2)
        echo ""
        echo "🚀 Starting interactive demo..."
        echo "   (You'll be prompted before each phase)"
        echo ""
        sleep 2
        NO_WAIT=false ./demo.sh $DEBUG_FLAG $VERBOSE_FLAG
        ;;
    3)
        echo ""
        echo "✅ LocalStack is running at http://localhost:4566"
        echo "   API endpoint will be: http://localhost:5000"
        echo ""
        echo "To stop: cd localstack && docker-compose down"
        ;;
    4)
        echo ""
        echo "👋 Exiting. Cleaning up..."
        cd localstack && docker-compose down
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid option. Exiting."
        exit 1
        ;;
esac

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Demo complete! Thank you!"
echo "════════════════════════════════════════════════════════════"
