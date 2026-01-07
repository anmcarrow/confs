# LocalStack JSON Response Visibility

## Overview

All LocalStack API interactions now display full JSON responses in stdout, making it easy to see what's happening during deployment and testing.

## What's Visible

### During Deployment (deploy-local.sh)

**DynamoDB Table Creation:**
```bash
📋 Creating DynamoDB table: tasks

{
  "TableDescription": {
    "TableName": "tasks",
    "TableStatus": "ACTIVE",
    "KeySchema": [...],
    "AttributeDefinitions": [...],
    "TableArn": "arn:aws:dynamodb:us-east-1:000000000000:table/tasks"
  }
}
```

**Table Verification:**
```bash
✅ Verifying table exists...

{
  "TableName": "tasks",
  "TableStatus": "ACTIVE",
  "ItemCount": 0,
  "TableArn": "arn:aws:dynamodb:us-east-1:000000000000:table/tasks"
}
```

### During Testing (test-endpoints.sh)

**Health Check:**
```bash
1️⃣  GET /health - Health Check

{
  "status": "healthy",
  "timestamp": "2026-01-06T23:48:00Z"
}
```

**Create Task:**
```bash
2️⃣  POST /tasks - Create New Task
Request body: {"title": "Test Task", "description": "Demo task"}

{
  "id": "abc123",
  "title": "Test Task",
  "description": "Demo task",
  "completed": false,
  "created_at": "2026-01-06T23:48:00Z"
}
```

**List Tasks:**
```bash
3️⃣  GET /tasks - List All Tasks

{
  "tasks": [
    {
      "id": "abc123",
      "title": "Test Task",
      "completed": false
    }
  ],
  "count": 1
}
```

**Get Single Task:**
```bash
4️⃣  GET /tasks/abc123 - Get Specific Task

{
  "id": "abc123",
  "title": "Test Task",
  "description": "Demo task",
  "completed": false,
  "created_at": "2026-01-06T23:48:00Z"
}
```

**Update Task:**
```bash
5️⃣  PUT /tasks/abc123 - Update Task
Request body: {"title": "Updated Task", "completed": true}

{
  "id": "abc123",
  "title": "Updated Task",
  "completed": true,
  "updated_at": "2026-01-06T23:49:00Z"
}
```

**Delete Task:**
```bash
6️⃣  DELETE /tasks/abc123 - Delete Task

{
  "message": "Task deleted successfully",
  "id": "abc123"
}
```

## Implementation Details

### AWS CLI Commands

All AWS CLI commands use:
- `--output json` flag for JSON responses
- `--endpoint-url http://localhost:4566` for LocalStack
- Response piped through `jq` for pretty-printing (if available)
- Fallback to raw JSON if jq not installed

Example:
```bash
aws dynamodb create-table \
    --table-name tasks \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:4566 \
    --output json | jq '.'
```

### cURL Commands

All API tests use:
- `-s` flag for clean output
- Response stored in variable
- Pretty-printed with `jq` or displayed raw
- Descriptive echo statements before each call
- Color-coded output (yellow for requests, cyan for info)

Example:
```bash
echo -e "${YELLOW}POST /tasks - Create Task${RESET}"
RESPONSE=$(curl -s -X POST "http://localhost:5000/tasks" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test"}')
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
```

### Color Coding

- 🟡 **Yellow**: Request headers and operations
- 🔵 **Cyan**: Informational messages and URLs
- 🟢 **Green**: Success messages
- ⚪ **White**: JSON responses

## Prompt Updates

The deployment prompt (`prompts/05-deployment.txt`) now includes:

```
IMPORTANT: Make ALL LocalStack API interactions visible:
- Every AWS CLI command should echo its JSON output
- Every curl command should display the response
- Add descriptive echo statements before each operation
- Use colors if possible (green for success, yellow for requests)
```

## Demo Flow Updates

Phase 5 (Deployment) now shows:

1. **Before deployment:**
   ```
   📡 Creating DynamoDB table and deploying Lambda...
   ```

2. **During deployment:**
   - Full JSON response from table creation
   - Table verification with JSON output
   - Lambda deployment responses (if used)

3. **Before testing:**
   ```
   🧪 Running API endpoint tests with JSON responses...
   ```

4. **During testing:**
   - Each endpoint test clearly labeled (1️⃣ 2️⃣ 3️⃣ etc.)
   - Request body shown for POST/PUT
   - Full JSON response displayed
   - Color-coded for readability

## Example Scripts

Reference implementations in `demo-records/`:

- `example-deploy-local.sh` - Shows how to display AWS CLI JSON responses
- `example-test-endpoints.sh` - Shows how to display API JSON responses

These serve as templates for AI generation.

## Usage

### Standard Demo
```bash
./run-demo.sh
# JSON responses visible in Phase 5
```

### With Verbose Mode
```bash
./demo.sh --verbose
# Shows command execution AND JSON responses
```

### Non-Interactive
```bash
./run-demo-auto.sh --verbose
# Automated with full JSON visibility
```

## Benefits

### For Presentations
- ✅ Audience sees actual AWS/DynamoDB responses
- ✅ Demonstrates real API interactions
- ✅ Shows data flow clearly
- ✅ Builds credibility

### For Development
- ✅ Easier debugging
- ✅ Verify data structure
- ✅ Check response codes
- ✅ Understand API behavior

### For Learning
- ✅ See AWS CLI output format
- ✅ Understand REST API responses
- ✅ Learn JSON structure
- ✅ Follow data transformations

## Troubleshooting

### JSON not displayed

**Check 1: AWS CLI output**
```bash
# Verify --output json is used
grep "output json" output/service/deploy-local.sh
```

**Check 2: jq installed**
```bash
# Install if missing
brew install jq  # macOS
apt-get install jq  # Linux
```

**Check 3: curl responses**
```bash
# Verify response stored and displayed
grep "echo.*RESPONSE" output/service/test-endpoints.sh
```

### Malformed JSON

If JSON appears broken:
1. Check curl command has `-s` flag (silent mode)
2. Verify Content-Type header for POST/PUT
3. Check for stderr mixed with stdout
4. Use `2>/dev/null` to suppress errors

### Colors not showing

If colors don't display:
1. Check terminal supports ANSI colors
2. Verify color variables defined (GREEN, CYAN, etc.)
3. Try without colors: pipe output through `cat`

## Configuration

### Customize Colors

In generated scripts, adjust these variables:
```bash
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'
```

### Control JSON Formatting

```bash
# Pretty-print with jq (if available)
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"

# Always use jq (fail if not available)
echo "$RESPONSE" | jq '.'

# Always raw JSON (no jq)
echo "$RESPONSE"

# Compact JSON
echo "$RESPONSE" | jq -c '.'
```

### Filter JSON Fields

Show only specific fields:
```bash
# DynamoDB table summary
echo "$RESPONSE" | jq '.Table | {TableName, TableStatus, ItemCount}'

# API response ID only
echo "$RESPONSE" | jq '.id'

# Array of task titles
echo "$RESPONSE" | jq '.tasks[].title'
```

## Related Documentation

- [README.md](../README.md) - Main documentation
- [VERBOSE_MODE.md](VERBOSE_MODE.md) - Verbose output guide
- [NON_INTERACTIVE_MODE.md](NON_INTERACTIVE_MODE.md) - Automation
- [DEMO_FLOW.md](DEMO_FLOW.md) - Pipeline overview

## Summary

All LocalStack API calls now display:
- ✅ Full JSON responses
- ✅ Color-coded output
- ✅ Descriptive labels
- ✅ Pretty-printed (when jq available)
- ✅ Request/response pairs
- ✅ Clear operation flow

Perfect for presentations, demos, and learning!
