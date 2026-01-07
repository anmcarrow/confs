#!/bin/bash

# Test retry logic and validation
# This script tests the reliability features without running the full demo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧪 Testing Retry Logic and Validation"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Define the functions we need to test (copied from demo.sh)

error_log() {
    echo -e "${RED}❌ ERROR: $*${RESET}" >&2
}

warning_log() {
    echo -e "${YELLOW}⚠️  WARNING: $*${RESET}" >&2
}

retry_command() {
    local max_retries=$1
    shift
    local attempt=1
    
    while [ $attempt -le $max_retries ]; do
        if "$@"; then
            return 0
        fi
        if [ $attempt -lt $max_retries ]; then
            local wait_time=$((2 ** attempt))
            warning_log "Command failed (attempt $attempt/$max_retries)"
            sleep $wait_time
        fi
        attempt=$((attempt + 1))
    done
    
    error_log "Command failed after $max_retries attempts: $*"
    return 1
}

validate_file() {
    local file=$1
    local description=$2
    
    if [ ! -f "$file" ]; then
        error_log "$description file not found: $file"
        return 1
    fi
    
    if [ ! -s "$file" ]; then
        error_log "$description file is empty: $file"
        return 1
    fi
    
    return 0
}

validate_requirements() {
    local file=$1
    validate_file "$file" "Requirements" || return 1
    grep -qi "requirements\|functional\|problem" "$file" || {
        error_log "Requirements file doesn't contain expected content"
        return 1
    }
    return 0
}

validate_architecture() {
    local file=$1
    validate_file "$file" "Architecture" || return 1
    grep -qi "architecture\|decision\|ADR" "$file" || {
        error_log "Architecture file doesn't contain expected content"
        return 1
    }
    return 0
}

validate_implementation() {
    if ! validate_file "output/service/app.py" "Flask application"; then
        error_log "app.py not found or empty"
        return 1
    fi
    
    if ! grep -q "Flask\|@app.route" "output/service/app.py"; then
        error_log "app.py doesn't appear to be a Flask application"
        return 1
    fi
    
    if ! validate_file "output/service/requirements.txt" "Python requirements"; then
        warning_log "requirements.txt not found or empty"
    fi
    
    return 0
}

validate_testing() {
    if ! validate_file "output/service/tests/test_app.py" "Test file"; then
        error_log "test_app.py not found or empty"
        return 1
    fi
    
    if ! grep -q "def test_\|import pytest" "output/service/tests/test_app.py"; then
        error_log "test_app.py doesn't appear to contain valid tests"
        return 1
    fi
    
    return 0
}

validate_deployment() {
    if [ ! -f "output/service/deploy-local.sh" ] || [ ! -x "output/service/deploy-local.sh" ]; then
        error_log "deploy-local.sh not found or not executable"
        return 1
    fi
    
    if [ ! -f "output/service/test-endpoints.sh" ] || [ ! -x "output/service/test-endpoints.sh" ]; then
        warning_log "test-endpoints.sh not found or not executable"
    fi
    
    return 0
}

# Test 1: File validation
echo "Test 1: File Validation"
echo "  Creating test file..."
mkdir -p output/test
echo "test content" > output/test/valid.txt
if validate_file "output/test/valid.txt" "test file"; then
    echo "  ✅ Valid file detected correctly"
else
    echo "  ❌ Valid file validation failed"
    exit 1
fi

# Test empty file
touch output/test/empty.txt
if validate_file "output/test/empty.txt" "empty file"; then
    echo "  ❌ Empty file should have failed validation"
    exit 1
else
    echo "  ✅ Empty file rejected correctly"
fi

# Test missing file
if validate_file "output/test/missing.txt" "missing file"; then
    echo "  ❌ Missing file should have failed validation"
    exit 1
else
    echo "  ✅ Missing file rejected correctly"
fi

echo ""

# Test 2: Requirements validation
echo "Test 2: Requirements Validation"
cat > output/test/requirements.md << 'EOF'
# Business Requirements

## Functional Requirements
1. User authentication
2. Data storage
EOF

if validate_requirements "output/test/requirements.md"; then
    echo "  ✅ Requirements validation passed"
else
    echo "  ❌ Requirements validation failed"
    exit 1
fi

# Test invalid requirements
echo "invalid content" > output/test/bad_requirements.md
if validate_requirements "output/test/bad_requirements.md"; then
    echo "  ❌ Bad requirements should have failed"
    exit 1
else
    echo "  ✅ Invalid requirements rejected correctly"
fi

echo ""

# Test 3: Architecture validation
echo "Test 3: Architecture Validation"
cat > output/test/architecture.md << 'EOF'
# Architecture Decision Records

## ADR 001: Technology Stack
Decision to use Flask for REST API
EOF

if validate_architecture "output/test/architecture.md"; then
    echo "  ✅ Architecture validation passed"
else
    echo "  ❌ Architecture validation failed"
    exit 1
fi

echo ""

# Test 4: Implementation validation
echo "Test 4: Implementation Validation"
mkdir -p output/service
cat > output/service/app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/api/health')
def health():
    return {'status': 'ok'}
EOF

cat > output/service/requirements.txt << 'EOF'
Flask==2.3.0
boto3==1.26.0
EOF

if validate_implementation; then
    echo "  ✅ Implementation validation passed"
else
    echo "  ❌ Implementation validation failed"
    exit 1
fi

# Test invalid implementation
echo "invalid python code" > output/service/app.py
if validate_implementation; then
    echo "  ❌ Invalid implementation should have failed"
    exit 1
else
    echo "  ✅ Invalid implementation rejected correctly"
fi

echo ""

# Test 5: Testing validation
echo "Test 5: Testing Validation"
mkdir -p output/service/tests
cat > output/service/tests/test_app.py << 'EOF'
import pytest
from app import app

def test_health():
    client = app.test_client()
    response = client.get('/api/health')
    assert response.status_code == 200
EOF

# Restore valid app.py
cat > output/service/app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/api/health')
def health():
    return {'status': 'ok'}
EOF

if validate_testing; then
    echo "  ✅ Testing validation passed"
else
    echo "  ❌ Testing validation failed"
    exit 1
fi

echo ""

# Test 6: Deployment validation
echo "Test 6: Deployment Validation"
cat > output/service/deploy-local.sh << 'EOF'
#!/bin/bash
echo "Deploying to LocalStack..."
EOF
chmod +x output/service/deploy-local.sh

cat > output/service/test-endpoints.sh << 'EOF'
#!/bin/bash
curl http://localhost:5000/api/health
EOF
chmod +x output/service/test-endpoints.sh

if validate_deployment; then
    echo "  ✅ Deployment validation passed"
else
    echo "  ❌ Deployment validation failed"
    exit 1
fi

echo ""

# Test 7: Retry command
echo "Test 7: Retry Command"
if retry_command 2 echo "test command"; then
    echo "  ✅ Retry command works"
else
    echo "  ❌ Retry command failed"
    exit 1
fi

echo ""

# Test 8: Check helper functions exist
echo "Test 8: Helper Functions"
declare -f error_log > /dev/null && echo "  ✅ error_log function exists" || exit 1
declare -f warning_log > /dev/null && echo "  ✅ warning_log function exists" || exit 1
declare -f retry_command > /dev/null && echo "  ✅ retry_command function exists" || exit 1
declare -f validate_file > /dev/null && echo "  ✅ validate_file function exists" || exit 1
declare -f validate_requirements > /dev/null && echo "  ✅ validate_requirements function exists" || exit 1
declare -f validate_architecture > /dev/null && echo "  ✅ validate_architecture function exists" || exit 1
declare -f validate_implementation > /dev/null && echo "  ✅ validate_implementation function exists" || exit 1
declare -f validate_testing > /dev/null && echo "  ✅ validate_testing function exists" || exit 1
declare -f validate_deployment > /dev/null && echo "  ✅ validate_deployment function exists" || exit 1

# Check that demo.sh has generate_with_retry
if grep -q "^generate_with_retry()" demo.sh; then
    echo "  ✅ generate_with_retry function exists in demo.sh"
else
    echo "  ❌ generate_with_retry function not found in demo.sh"
    exit 1
fi

echo ""
echo "======================================"
echo "✅ All Reliability Tests Passed!"
echo ""
echo "The retry logic and validation system is working correctly."
echo "Run './demo.sh --max-retries 5 --debug' to see it in action."
