#!/bin/bash

########################
# Live Demo Script
# AI-Driven Development Pipeline
########################

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Source demo-magic
source ./lib/demo-magic.sh

# Source visualizations
source ./lib/visualizations.sh

# Override wait function for auto mode with random delays
if [ "$NO_WAIT" = true ]; then
    wait() {
        # Random sleep between 3-5 seconds in auto mode
        local sleep_time=$((3 + RANDOM % 3))
        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}[AUTO-WAIT: ${sleep_time}s]${RESET}" >&2
        fi
        sleep $sleep_time
    }
fi

# Configuration
TYPE_SPEED=40
DEMO_PROMPT="${GREEN}➜ ${CYAN}ai-demo${COLOR_RESET} "
NO_WAIT=false
DEBUG_MODE=false
VERBOSE=false
MAX_RETRIES=3

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG_MODE=true
            set -x  # Enable bash debug mode
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --max-retries)
            MAX_RETRIES="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Colors
BOLD="\033[1m"
RESET="\033[0m"
BLUE="\033[34m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"

# Helper functions
debug_log() {
    if [ "$DEBUG_MODE" = true ]; then
        echo -e "${YELLOW}[DEBUG]${RESET} $1" >&2
    fi
}

verbose_log() {
    if [ "$VERBOSE" = true ] || [ "$DEBUG_MODE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${RESET} $1" >&2
    fi
}

error_log() {
    echo -e "${BOLD}${RED}[ERROR]${RESET} $1" >&2
}

warning_log() {
    echo -e "${YELLOW}[WARNING]${RESET} $1" >&2
}

# Retry wrapper for commands
retry_command() {
    local max_attempts=$1
    shift
    local attempt=1
    local exit_code=0
    
    while [ $attempt -le $max_attempts ]; do
        debug_log "Attempt $attempt of $max_attempts: $*"
        
        if "$@"; then
            debug_log "Command succeeded on attempt $attempt"
            return 0
        fi
        
        exit_code=$?
        error_log "Command failed with exit code $exit_code (attempt $attempt of $max_attempts)"
        
        if [ $attempt -lt $max_attempts ]; then
            warning_log "Retrying in 2 seconds..."
            sleep 2
        fi
        
        attempt=$((attempt + 1))
    done
    
    error_log "Command failed after $max_attempts attempts"
    return $exit_code
}

# Validate file exists and is not empty
validate_file() {
    local file=$1
    local description=$2
    
    debug_log "Validating file: $file"
    
    if [ ! -f "$file" ]; then
        error_log "File not found: $file ($description)"
        return 1
    fi
    
    if [ ! -s "$file" ]; then
        error_log "File is empty: $file ($description)"
        return 1
    fi
    
    debug_log "File validation passed: $file"
    return 0
}

# Check if file contains executable bash commands
is_executable_bash() {
    local file=$1
    
    # Check if file exists and is not empty
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        return 1
    fi
    
    # Check if file starts with shebang
    if head -n 1 "$file" | grep -q "^#!/bin/bash"; then
        debug_log "File has bash shebang: $file"
        return 0
    fi
    
    # Check if file contains bash commands (mkdir, cat, chmod, etc.) without markdown
    # and doesn't contain Copilot's explanatory output markers (✓, checkmarks, etc.)
    if grep -q "^mkdir -p\|^cat >\|^chmod +x" "$file" 2>/dev/null && \
       ! grep -q "^✓\|^I'll\|^I've" "$file" 2>/dev/null; then
        debug_log "File contains bash commands: $file"
        return 0
    fi
    
    debug_log "File does not appear to be executable bash: $file"
    return 1
}

# Generate with retry logic
generate_with_retry() {
    local phase_name=$1
    local prompt_file=$2
    local output_file=$3
    local validation_func=$4
    local execute_as_bash="${5:-false}"  # Optional 5th parameter, defaults to false
    
    # Normalize to lowercase for consistent comparison
    execute_as_bash=$(echo "$execute_as_bash" | tr '[:upper:]' '[:lower:]')
    
    debug_log "execute_as_bash parameter: '$execute_as_bash'"
    
    local attempt=1
    
    # Ensure output directory exists
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    while [ $attempt -le $MAX_RETRIES ]; do
        echo ""
        if [ $attempt -gt 1 ]; then
            warning_log "Retry attempt $attempt of $MAX_RETRIES for $phase_name"
            echo ""
        fi
        
        verbose_log "Starting generation for $phase_name (attempt $attempt/$MAX_RETRIES)"
        verbose_log "Prompt file: $prompt_file"
        verbose_log "Output file: $output_file"
        
        # Start spinner for generation
        if [ "$VERBOSE" = false ] && [ "$DEBUG_MODE" = false ]; then
            start_spinner "🤖 AI is generating $phase_name..."
        fi
        
        # Track if generation succeeded
        local generation_succeeded=false
        
        # Run generation
        if [ "$HAS_COPILOT" = true ]; then
            debug_log "Using copilot for generation"
            verbose_log "Executing: cat $prompt_file | copilot --allow-all-tools"
            if [ "$VERBOSE" = true ]; then
                # Stop spinner before showing output
                stop_spinner
                # In verbose mode, show output with tee
                if cat "$prompt_file" | copilot --allow-all-tools | tee "$output_file"; then
                    verbose_log "Copilot generation completed"
                    generation_succeeded=true
                else
                    error_log "Copilot generation failed"
                fi
            else
                # Normal mode, redirect to file
                if cat "$prompt_file" | copilot --allow-all-tools > "$output_file" 2>&1; then
                    debug_log "Copilot generation completed"
                    generation_succeeded=true
                else
                    error_log "Copilot generation failed"
                fi
            fi
            
            # Execute the generated bash script if generation succeeded and execute_as_bash is true
            debug_log "Checking execution: generation_succeeded='$generation_succeeded' execute_as_bash='$execute_as_bash'"
            if [ "$generation_succeeded" = "true" ] && [ "$execute_as_bash" = "true" ]; then
                # Verify the file is actually executable bash before running it
                if is_executable_bash "$output_file"; then
                    debug_log "Executing generated bash script from $output_file"
                    verbose_log "Running bash commands from Copilot output"
                    if [ "$VERBOSE" = true ]; then
                        # In verbose mode, show execution
                        if bash "$output_file"; then
                            verbose_log "Bash script execution completed"
                        else
                            error_log "Bash script execution failed"
                            generation_succeeded=false
                        fi
                    else
                        # Normal mode, execute silently
                        if bash "$output_file" 2>&1 | tee -a "$output_file.exec.log" > /dev/null; then
                            debug_log "Bash script execution completed"
                        else
                            error_log "Bash script execution failed (see $output_file.exec.log)"
                            generation_succeeded=false
                        fi
                    fi
                else
                    warning_log "Output file does not contain executable bash commands - likely Copilot generated explanatory text"
                    debug_log "Copilot may have created files directly using --allow-all-tools instead of generating bash script"
                fi
            else
                debug_log "Skipping bash execution (not a bash script or generation failed)"
            fi
        else
            debug_log "Using simulated response"
            verbose_log "Copilot not available, using simulation"
            simulate_ai_response "$prompt_file" "$output_file"
            generation_succeeded=true
        fi
        
        # Stop spinner
        if [ "$VERBOSE" = false ] && [ "$DEBUG_MODE" = false ]; then
            stop_spinner
        fi
        
        # Only validate if generation succeeded
        if [ "$generation_succeeded" = false ]; then
            error_log "Generation command failed, skipping validation"
            attempt=$((attempt + 1))
            if [ $attempt -le $MAX_RETRIES ]; then
                warning_log "Retrying generation..."
                sleep $((2 ** (attempt - 1)))  # Exponential backoff
            fi
            continue
        fi
        
        # Validate output
        if [ -n "$validation_func" ] && type "$validation_func" &>/dev/null; then
            debug_log "Running validation: $validation_func"
            if $validation_func "$output_file"; then
                echo -e "${GREEN}✅ $phase_name completed successfully${RESET}"
                return 0
            else
                error_log "$phase_name validation failed"
            fi
        else
            # Basic file validation if no custom validator
            if validate_file "$output_file" "$phase_name"; then
                echo -e "${GREEN}✅ $phase_name completed successfully${RESET}"
                return 0
            fi
        fi
        
        attempt=$((attempt + 1))
        
        if [ $attempt -le $MAX_RETRIES ]; then
            warning_log "Generation failed validation, retrying..."
            sleep $((2 ** (attempt - 1)))  # Exponential backoff
        fi
    done
    
    error_log "$phase_name failed after $MAX_RETRIES attempts"
    return 1
}

print_banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║        AI-DRIVEN DEVELOPMENT PIPELINE                      ║"
    echo "║        From Concept to Cloud in 15 Minutes                 ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
}

print_phase() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${CYAN}$1${RESET}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

check_copilot() {
    debug_log "Checking for copilot CLI..."
    if ! command -v copilot &> /dev/null; then
        debug_log "copilot not found, will use simulation"
        echo -e "${YELLOW}⚠️  copilot CLI not found. This demo will simulate AI calls.${RESET}"
        echo -e "${YELLOW}   To install: GitHub Copilot CLI${RESET}"
        echo ""
        sleep 2
        return 1
    fi
    debug_log "copilot found at: $(which copilot)"
    echo -e "${GREEN}✅ copilot found - using real AI generation${RESET}"
    echo ""
    return 0
}

simulate_ai_response() {
    local prompt_file=$1
    local output_file=$2
    
    debug_log "Simulating AI response for: $prompt_file -> $output_file"
    echo -e "${GREEN}🤖 AI Agent Processing...${RESET}"
    sleep 2
    
    # Simulate AI response based on the phase
    case "$prompt_file" in
        *01-concept*)
            cat > "$output_file" << 'EOF'
# Task Management API - Requirements Document

## Problem Statement
Teams need a simple, reliable way to track and manage tasks without the overhead of complex project management tools.

## Functional Requirements
1. **Create Task**: Users can create new tasks with title, description
2. **List Tasks**: View all tasks with filtering by status
3. **Get Task**: Retrieve details of a specific task by ID
4. **Update Task**: Modify task details and status
5. **Delete Task**: Remove tasks from the system
6. **Status Management**: Tasks can be in todo, in-progress, or done states
7. **Timestamps**: Automatically track created_at and updated_at

## Non-Functional Requirements
- **Performance**: API response time < 200ms for single operations
- **Scalability**: Support 1000+ concurrent users
- **Availability**: 99.9% uptime
- **Security**: Authentication and authorization for all endpoints

## Success Criteria
- All CRUD operations working correctly
- API follows REST conventions
- Successfully deployed to cloud infrastructure
- Automated tests with 80%+ coverage
EOF
            ;;
        *02-architecture*)
            cat > "$output_file" << 'EOF'
# Architecture Decision Records

## ADR 1: Technology Stack

**Context**: Need serverless, scalable solution with rapid development

**Decision**: 
- Python 3.11 + Flask for API
- DynamoDB for NoSQL storage
- AWS Lambda + API Gateway for serverless deployment

**Consequences**:
✅ Fast development cycle
✅ Auto-scaling capabilities
✅ Pay-per-use pricing
⚠️  Cold start latency
⚠️  AWS vendor lock-in

## ADR 2: API Design

**Decision**: RESTful API structure
- POST /tasks - Create task
- GET /tasks - List all tasks
- GET /tasks/{id} - Get specific task
- PUT /tasks/{id} - Update task
- DELETE /tasks/{id} - Delete task

**Consequences**:
✅ Standard HTTP methods
✅ Predictable URL structure
✅ Easy to document and test

## ADR 3: Data Model

**Decision**: DynamoDB single-table design
- Primary Key: task_id (UUID)
- Attributes: title, description, status, created_at, updated_at
- GSI on status for filtering

**Consequences**:
✅ Fast reads/writes
✅ Flexible schema
⚠️  No complex queries without GSI
EOF
            ;;
        *03-implementation*)
            mkdir -p output/service
            
            # Create app.py
            cat > output/service/app.py << 'EOF'
import json
import uuid
import os
from datetime import datetime
import boto3
from flask import Flask, request, jsonify

app = Flask(__name__)

# DynamoDB setup
dynamodb = boto3.resource('dynamodb', endpoint_url=os.getenv('DYNAMODB_ENDPOINT', None))
table_name = os.getenv('TABLE_NAME', 'tasks')

def get_table():
    return dynamodb.Table(table_name)

@app.route('/tasks', methods=['POST'])
def create_task():
    data = request.json
    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400
    
    task_id = str(uuid.uuid4())
    timestamp = datetime.utcnow().isoformat()
    
    task = {
        'task_id': task_id,
        'title': data['title'],
        'description': data.get('description', ''),
        'status': data.get('status', 'todo'),
        'created_at': timestamp,
        'updated_at': timestamp
    }
    
    table = get_table()
    table.put_item(Item=task)
    
    return jsonify(task), 201

@app.route('/tasks', methods=['GET'])
def list_tasks():
    table = get_table()
    response = table.scan()
    return jsonify(response.get('Items', [])), 200

@app.route('/tasks/<task_id>', methods=['GET'])
def get_task(task_id):
    table = get_table()
    response = table.get_item(Key={'task_id': task_id})
    
    if 'Item' not in response:
        return jsonify({'error': 'Task not found'}), 404
    
    return jsonify(response['Item']), 200

@app.route('/tasks/<task_id>', methods=['PUT'])
def update_task(task_id):
    data = request.json
    table = get_table()
    
    # Check if task exists
    response = table.get_item(Key={'task_id': task_id})
    if 'Item' not in response:
        return jsonify({'error': 'Task not found'}), 404
    
    # Update task
    update_expr = "SET updated_at = :updated_at"
    expr_values = {':updated_at': datetime.utcnow().isoformat()}
    
    if 'title' in data:
        update_expr += ", title = :title"
        expr_values[':title'] = data['title']
    if 'description' in data:
        update_expr += ", description = :description"
        expr_values[':description'] = data['description']
    if 'status' in data:
        update_expr += ", #status = :status"
        expr_values[':status'] = data['status']
    
    table.update_item(
        Key={'task_id': task_id},
        UpdateExpression=update_expr,
        ExpressionAttributeValues=expr_values,
        ExpressionAttributeNames={'#status': 'status'} if 'status' in data else None
    )
    
    # Get updated task
    response = table.get_item(Key={'task_id': task_id})
    return jsonify(response['Item']), 200

@app.route('/tasks/<task_id>', methods=['DELETE'])
def delete_task(task_id):
    table = get_table()
    
    # Check if task exists
    response = table.get_item(Key={'task_id': task_id})
    if 'Item' not in response:
        return jsonify({'error': 'Task not found'}), 404
    
    table.delete_item(Key={'task_id': task_id})
    return '', 204

# Lambda handler
def lambda_handler(event, context):
    from werkzeug.wrappers import Request, Response
    
    request_data = {
        'method': event['httpMethod'],
        'path': event['path'],
        'headers': event['headers'],
        'body': event.get('body', ''),
        'query_string': event.get('queryStringParameters', {})
    }
    
    with app.request_context(request_data):
        response = app.full_dispatch_request()
        return {
            'statusCode': response.status_code,
            'body': response.get_data(as_text=True),
            'headers': dict(response.headers)
        }

if __name__ == '__main__':
    app.run(debug=True, port=5000)
EOF

            # Create requirements.txt
            cat > output/service/requirements.txt << 'EOF'
Flask==3.0.0
boto3==1.34.0
Werkzeug==3.0.1
EOF

            # Create README
            cat > output/service/README.md << 'EOF'
# Task Management API

REST API for managing tasks built with Flask, DynamoDB, and AWS Lambda.

## Local Development

```bash
pip install -r requirements.txt
export TABLE_NAME=tasks
export DYNAMODB_ENDPOINT=http://localhost:4566
python app.py
```

## API Endpoints

- POST /tasks - Create task
- GET /tasks - List all tasks
- GET /tasks/{id} - Get task
- PUT /tasks/{id} - Update task
- DELETE /tasks/{id} - Delete task

## Deployment

See deploy-local.sh for LocalStack deployment.
EOF

            echo "✅ Generated: app.py, requirements.txt, README.md" > "$output_file"
            ;;
        *04-testing*)
            mkdir -p output/service/tests
            
            cat > output/service/tests/test_app.py << 'EOF'
import pytest
import json
from moto import mock_dynamodb
import boto3
from app import app, table_name

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@pytest.fixture
def dynamodb_table():
    with mock_dynamodb():
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.create_table(
            TableName=table_name,
            KeySchema=[{'AttributeName': 'task_id', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'task_id', 'AttributeType': 'S'}],
            BillingMode='PAY_PER_REQUEST'
        )
        yield table

def test_create_task(client, dynamodb_table):
    response = client.post('/tasks', 
        data=json.dumps({'title': 'Test Task', 'description': 'Test Description'}),
        content_type='application/json')
    
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['title'] == 'Test Task'
    assert 'task_id' in data

def test_list_tasks(client, dynamodb_table):
    response = client.get('/tasks')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)

def test_create_task_missing_title(client, dynamodb_table):
    response = client.post('/tasks', 
        data=json.dumps({}),
        content_type='application/json')
    
    assert response.status_code == 400
EOF

            cat > output/service/test-requirements.txt << 'EOF'
pytest==7.4.3
moto==4.2.0
pytest-cov==4.1.0
EOF

            echo "✅ Generated: test_app.py, test-requirements.txt" > "$output_file"
            ;;
        *05-deployment*)
            cat > output/service/deploy-local.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Deploying to LocalStack..."

# Set LocalStack endpoint
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# Create DynamoDB table
echo "📦 Creating DynamoDB table..."
aws dynamodb create-table \
    --endpoint-url $AWS_ENDPOINT_URL \
    --table-name tasks \
    --attribute-definitions AttributeName=task_id,AttributeType=S \
    --key-schema AttributeName=task_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_DEFAULT_REGION 2>/dev/null || echo "Table already exists"

echo "✅ Deployment complete!"
echo "📍 DynamoDB Endpoint: http://localhost:4566"
echo "📍 API Endpoint: http://localhost:5000"
EOF

            chmod +x output/service/deploy-local.sh

            cat > output/service/test-endpoints.sh << 'EOF'
#!/bin/bash

API_URL="http://localhost:5000"

echo "🧪 Testing Task Management API..."
echo ""

# Create task
echo "1️⃣  Creating task..."
TASK_ID=$(curl -s -X POST $API_URL/tasks \
    -H "Content-Type: application/json" \
    -d '{"title":"Demo Task","description":"Created by demo","status":"todo"}' \
    | jq -r '.task_id')

echo "   Created task: $TASK_ID"
echo ""

# List tasks
echo "2️⃣  Listing all tasks..."
curl -s -X GET $API_URL/tasks | jq '.'
echo ""

# Get specific task
echo "3️⃣  Getting task details..."
curl -s -X GET $API_URL/tasks/$TASK_ID | jq '.'
echo ""

# Update task
echo "4️⃣  Updating task status..."
curl -s -X PUT $API_URL/tasks/$TASK_ID \
    -H "Content-Type: application/json" \
    -d '{"status":"in-progress"}' | jq '.'
echo ""

# Delete task
echo "5️⃣  Deleting task..."
curl -s -X DELETE $API_URL/tasks/$TASK_ID
echo "   Task deleted"
echo ""

echo "✅ All tests completed!"
EOF

            chmod +x output/service/test-endpoints.sh
            
            echo "✅ Generated: deploy-local.sh, test-endpoints.sh" > "$output_file"
            ;;
    esac
    
    echo -e "${GREEN}✅ Response saved to: $output_file${RESET}"
}

# Validation functions for each phase
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
    # Check if app.py was created
    if ! validate_file "output/service/app.py" "Flask application"; then
        error_log "app.py not found or empty"
        return 1
    fi
    
    # Check if it contains Flask code
    if ! grep -q "Flask\|@app.route" "output/service/app.py"; then
        error_log "app.py doesn't appear to be a Flask application"
        return 1
    fi
    
    # Check for requirements.txt
    if ! validate_file "output/service/requirements.txt" "Python requirements"; then
        warning_log "requirements.txt not found or empty"
    fi
    
    return 0
}

validate_testing() {
    # Check if test file was created
    if ! validate_file "output/service/tests/test_app.py" "Test file"; then
        error_log "test_app.py not found or empty"
        return 1
    fi
    
    # Check if it contains test code
    if ! grep -q "def test_\|import pytest" "output/service/tests/test_app.py"; then
        error_log "test_app.py doesn't appear to contain valid tests"
        return 1
    fi
    
    return 0
}

validate_deployment() {
    # Check for deployment scripts
    if [ ! -f "output/service/deploy-local.sh" ] || [ ! -x "output/service/deploy-local.sh" ]; then
        error_log "deploy-local.sh not found or not executable"
        return 1
    fi
    
    if [ ! -f "output/service/test-endpoints.sh" ] || [ ! -x "output/service/test-endpoints.sh" ]; then
        warning_log "test-endpoints.sh not found or not executable"
    fi
    
    return 0
}

# Check if we have copilot
HAS_COPILOT=false
check_copilot && HAS_COPILOT=true

# Banner
print_banner
wait

# Introduction
pei "# Welcome to the AI-Driven Development Pipeline Demo!"
pei "# We'll go from concept to deployed API in minutes using AI agents."
echo ""
show_timeline 0
wait

# PHASE 1: CONCEPT
show_timeline 1
show_phase_badge 1 "Business Concept & Requirements"
print_phase "📋 PHASE 1: Business Concept & Requirements"
pei "# First, let's define what we want to build"
pe "cat prompts/01-concept.txt"
echo ""
wait

pei "# Sending to AI agent for requirements analysis..."
if ! generate_with_retry "Business Requirements" "prompts/01-concept.txt" "output/requirements.md" "validate_requirements" false; then
    error_log "Failed to generate requirements after $MAX_RETRIES attempts"
    exit 1
fi
echo ""
wait

pei "# Let's see what the AI generated:"
pe "cat output/requirements.md"
echo ""
wait

# Visualization: Requirements Analysis
show_requirements_chart
sleep 5
wait

# PHASE 2: ARCHITECTURE
show_timeline 2
show_phase_badge 2 "Architecture Design"
print_phase "🏗️  PHASE 2: Architecture Design & ADRs"
pei "# Now, let's design the system architecture"
pe "cat prompts/02-architecture.txt"
echo ""
wait

pei "# AI agent creating Architecture Decision Records..."
if ! generate_with_retry "Architecture ADRs" "prompts/02-architecture.txt" "output/architecture.md" "validate_architecture" false; then
    error_log "Failed to generate architecture after $MAX_RETRIES attempts"
    exit 1
fi
echo ""
wait

pei "# Architecture decisions:"
pe "cat output/architecture.md"
echo ""
wait

# Visualization: Architecture Components
show_architecture_chart
sleep 5
wait

# PHASE 3: IMPLEMENTATION
show_timeline 3
show_phase_badge 3 "Code Implementation"
print_phase "💻 PHASE 3: Code Generation"
pei "# Time to generate the actual code!"
pe "cat prompts/03-implementation.txt"
echo ""
wait

pei "# AI agent generating Flask application..."
if ! generate_with_retry "Flask Implementation" "prompts/03-implementation.txt" "output/implementation.log" "validate_implementation" true; then
    error_log "Failed to generate implementation after $MAX_RETRIES attempts"
    exit 1
fi
echo ""
wait

pei "# Let's see the generated code structure:"
if ! retry_command 3 ls -lah output/service/; then
    error_log "Service directory not created properly"
    exit 1
fi
echo ""
wait

pei "# Streaming generated code with syntax highlighting..."
if [ -f "output/service/app.py" ]; then
    stream_code_preview output/service/app.py 30
else
    warning_log "app.py not found, skipping code preview"
fi
wait
# Visualization: Code Generation Metrics
show_code_metrics_chart
sleep 5
wait

# PHASE 4: TESTING
show_timeline 4
show_phase_badge 4 "Testing"
print_phase "🧪 PHASE 4: Test Generation"
pei "# Generating comprehensive tests..."
if ! generate_with_retry "Test Suite" "prompts/04-testing.txt" "output/testing.log" "validate_testing" true; then
    error_log "Failed to generate tests after $MAX_RETRIES attempts"
    exit 1
fi
echo ""
wait

pei "# Test files generated:"
if ! retry_command 3 ls -lah output/service/tests/; then
    error_log "Tests directory not created properly"
    exit 1
fi
echo ""
wait

# Visualization: Test Coverage Metrics
show_test_coverage_chart
sleep 6
wait

# PHASE 5: DEPLOYMENT
show_timeline 5
show_phase_badge 5 "Deployment"
print_phase "🚀 PHASE 5: Deployment to LocalStack"
pei "# Generating deployment scripts..."
if ! generate_with_retry "Deployment Scripts" "prompts/05-deployment.txt" "output/deployment.log" "validate_deployment" true; then
    error_log "Failed to generate deployment scripts after $MAX_RETRIES attempts"
    exit 1
fi
echo ""
wait

pei "# Starting LocalStack..."
pe "cd localstack && docker-compose up -d && cd .."
sleep 3
echo ""

pei "# Deploying to LocalStack..."
if [ -d "output/service" ]; then
    echo ""
    echo -e "${CYAN}📡 Creating DynamoDB table and deploying Lambda...${RESET}"
    if [ -x "output/service/deploy-local.sh" ]; then
        pe "cd output/service && ./deploy-local.sh && cd ../.."
    else
        error_log "deploy-local.sh not found or not executable"
    fi
else
    error_log "output/service directory not found"
fi
echo ""
wait

pei "# Installing dependencies and starting the API..."
if [ -d "output/service" ] && [ -f "output/service/requirements.txt" ]; then
    pe "cd output/service && pip install -q -r requirements.txt && cd ../.."
    echo ""
    echo -e "${CYAN}🚀 Starting Flask API (TABLE_NAME=tasks, DYNAMODB_ENDPOINT=http://localhost:4566)...${RESET}"
    if [ -f "output/service/app.py" ]; then
        pe "export TABLE_NAME=tasks && export DYNAMODB_ENDPOINT=http://localhost:4566 && cd output/service && python app.py &"
    else
        error_log "app.py not found in output/service/"
    fi
    sleep 2
else
    error_log "Required files not found in output/service/"
fi
echo ""
wait

pei "# Testing the deployed API..."
if [ -d "output/service" ] && [ -x "output/service/test-endpoints.sh" ]; then
    echo ""
    echo -e "${CYAN}🧪 Running API endpoint tests with JSON responses...${RESET}"
    pe "cd output/service && ./test-endpoints.sh && cd ../.."
else
    error_log "test-endpoints.sh not found or not executable"
fi
echo ""
wait

# Visualization: Deployment Success
show_deployment_chart
sleep 6
wait

# Conclusion
print_phase "✅ DEMO COMPLETE"

# Show final completed timeline
show_timeline 6
echo ""

echo -e "${BOLD}${GREEN}Summary:${RESET}"
echo "  ✅ Requirements generated by AI"
echo "  ✅ Architecture designed by AI"
echo "  ✅ Code generated by AI"
echo "  ✅ Tests generated by AI"
echo "  ✅ Deployed to LocalStack"
echo "  ✅ API fully functional"
echo ""
echo -e "${BOLD}${CYAN}From concept to deployed API in minutes!${RESET}"
echo ""
echo -e "${YELLOW}Press any key to cleanup...${RESET}"
wait

# Cleanup
pei "# Cleaning up..."
pe "cd $SCRIPT_DIR"
pe "pkill -f 'python app.py' || true"
pe "cd localstack && docker-compose down && cd .."
echo ""
echo -e "${GREEN}✅ Demo cleanup complete!${RESET}"
