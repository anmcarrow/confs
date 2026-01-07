#!/bin/bash

# Example deploy-local.sh with visible JSON responses
# This serves as a reference for AI generation

set -e

LOCALSTACK_ENDPOINT="http://localhost:4566"
TABLE_NAME="tasks"
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${CYAN}🚀 Deploying to LocalStack...${RESET}"
echo ""

# Create DynamoDB Table
echo -e "${YELLOW}📋 Creating DynamoDB table: $TABLE_NAME${RESET}"
echo ""

RESPONSE=$(aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url "$LOCALSTACK_ENDPOINT" \
    --output json 2>&1)

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Verify table creation
echo -e "${YELLOW}✅ Verifying table exists...${RESET}"
echo ""

DESCRIBE_RESPONSE=$(aws dynamodb describe-table \
    --table-name "$TABLE_NAME" \
    --endpoint-url "$LOCALSTACK_ENDPOINT" \
    --output json 2>&1)

echo "$DESCRIBE_RESPONSE" | jq '.Table | {TableName, TableStatus, ItemCount, TableArn}' 2>/dev/null || echo "$DESCRIBE_RESPONSE"
echo ""

echo -e "${GREEN}✅ Deployment complete!${RESET}"
echo -e "${CYAN}📡 DynamoDB Table: $TABLE_NAME${RESET}"
echo -e "${CYAN}📍 Endpoint: $LOCALSTACK_ENDPOINT${RESET}"
echo ""
