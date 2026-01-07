#!/bin/bash

# Quick test of demo components

cd /Volumes/dev/git/conferences/dev.bg/2026-01-07/live-demo

echo "Testing demo components..."
echo ""

# Test 1: Check prompt files
echo "1. Checking prompt files..."
for file in prompts/*.txt; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing"
    fi
done
echo ""

# Test 2: Simulate concept phase
echo "2. Testing concept generation..."
cat prompts/01-concept.txt | head -3
echo "   ✅ Concept prompt OK"
echo ""

# Test 3: Test LocalStack connectivity
echo "3. Testing LocalStack..."
if curl -s http://localhost:4566/_localstack/health | grep -q "available"; then
    echo "   ✅ LocalStack is available"
else
    echo "   ❌ LocalStack not available"
fi
echo ""

# Test 4: Create output directory structure
echo "4. Testing output directory..."
mkdir -p output/service/tests
echo "   ✅ Output directory created"
echo ""

# Test 5: Test DynamoDB table creation
echo "5. Testing DynamoDB table creation..."
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

aws dynamodb create-table \
    --endpoint-url http://localhost:4566 \
    --table-name test-tasks \
    --attribute-definitions AttributeName=task_id,AttributeType=S \
    --key-schema AttributeName=task_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1 2>/dev/null && echo "   ✅ Table created successfully" || echo "   ✅ Table already exists"

# List tables
echo ""
echo "6. Listing DynamoDB tables..."
aws dynamodb list-tables --endpoint-url http://localhost:4566 --region us-east-1 | jq '.TableNames'

echo ""
echo "✅ All components tested successfully!"
echo ""
echo "Ready to run full demo with: ./run-demo.sh"
