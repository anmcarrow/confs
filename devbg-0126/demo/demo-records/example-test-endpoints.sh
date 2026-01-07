#!/bin/bash

# Example test-endpoints.sh with visible JSON responses
# This serves as a reference for AI generation

API_URL="${API_URL:-http://localhost:5000}"
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${CYAN}🧪 Testing API Endpoints${RESET}"
echo -e "${CYAN}📍 API URL: $API_URL${RESET}"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}1️⃣  GET /health - Health Check${RESET}"
echo ""
RESPONSE=$(curl -s "$API_URL/health")
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Test 2: Create Task
echo -e "${YELLOW}2️⃣  POST /tasks - Create New Task${RESET}"
echo -e "${CYAN}Request body: {\"title\": \"Test Task\", \"description\": \"Demo task\"}${RESET}"
echo ""
RESPONSE=$(curl -s -X POST "$API_URL/tasks" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Task","description":"Demo task"}')
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
TASK_ID=$(echo "$RESPONSE" | jq -r '.id' 2>/dev/null || echo "test-id")
echo ""

# Test 3: List All Tasks
echo -e "${YELLOW}3️⃣  GET /tasks - List All Tasks${RESET}"
echo ""
RESPONSE=$(curl -s "$API_URL/tasks")
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Test 4: Get Single Task
echo -e "${YELLOW}4️⃣  GET /tasks/$TASK_ID - Get Specific Task${RESET}"
echo ""
RESPONSE=$(curl -s "$API_URL/tasks/$TASK_ID")
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Test 5: Update Task
echo -e "${YELLOW}5️⃣  PUT /tasks/$TASK_ID - Update Task${RESET}"
echo -e "${CYAN}Request body: {\"title\": \"Updated Task\", \"completed\": true}${RESET}"
echo ""
RESPONSE=$(curl -s -X PUT "$API_URL/tasks/$TASK_ID" \
    -H "Content-Type: application/json" \
    -d '{"title":"Updated Task","completed":true}')
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Test 6: Delete Task
echo -e "${YELLOW}6️⃣  DELETE /tasks/$TASK_ID - Delete Task${RESET}"
echo ""
RESPONSE=$(curl -s -X DELETE "$API_URL/tasks/$TASK_ID")
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

echo -e "${GREEN}✅ All endpoint tests complete!${RESET}"
