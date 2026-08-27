#!/bin/bash
echo "🧪 Running Isolated AWS Lambda Verification Tests via Docker..."

# Define local temp directory relative to current folder
TEMP_DIR="$(pwd)/temp"
mkdir -p "$TEMP_DIR"

run_aws() {
  docker run --rm --network local-aws-net \
    -e AWS_ACCESS_KEY_ID=mock-key \
    -e AWS_SECRET_ACCESS_KEY=mock-secret \
    -e AWS_DEFAULT_REGION=us-east-1 \
    -v "$TEMP_DIR:$TEMP_DIR" \
    amazon/aws-cli --endpoint-url=http://floci-emulator:4566 "$@"
}

echo "👉 [1/4] Preparing Lambda Function Packages in $TEMP_DIR..."

# 1. Addition Lambda Source Code (Python)
cat << 'EOF' > "$TEMP_DIR/add_function.py"
def lambda_handler(event, context):
    num1 = event.get('num1', 0)
    num2 = event.get('num2', 0)
    result = num1 + num2
    return {
        'statusCode': 200,
        'body': {'sum': result, 'message': f"Successfully calculated {num1} + {num2}"}
    }
EOF

# 2. DocumentDB Fetcher Lambda Source Code (Python using pymongo)
cat << 'EOF' > "$TEMP_DIR/docdb_function.py"
import json
from datetime import datetime
from pymongo import MongoClient

def json_serial(obj):
    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} not serializable")

def lambda_handler(event, context):
    host = event.get('host', 'local-mongo-cluster')
    port = event.get('port', 27017)
    username = event.get('username', 'admin')
    password = event.get('password', 'password123')
    db_name = event.get('database', 'test_docdb')
    collection_name = event.get('collection', 'users')

    uri = f"mongodb://{username}:{password}@{host}:{port}/{db_name}?authSource=admin"
    
    try:
        client = MongoClient(uri, serverSelectionTimeoutMS=5000)
        db = client[db_name]
        collection = db[collection_name]
        
        raw_documents = list(collection.find({}, {'_id': 0}).limit(10))
        documents = json.loads(json.dumps(raw_documents, default=json_serial))
        
        return {
            'statusCode': 200,
            'count': len(documents),
            'documents': documents
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'error': str(e)
        }
EOF

# Package ZIP files silently
docker run --rm -v "$TEMP_DIR:/var/task" --entrypoint /bin/sh python:3.10-slim -c "
  export DEBIAN_FRONTEND=noninteractive && \
  cd /var/task && \
  apt-get update -qq && apt-get install -y -qq zip > /dev/null 2>&1 && \
  zip -q add_lambda.zip add_function.py && \
  pip install --quiet --target ./package pymongo && \
  cd package && zip -q -r ../docdb_lambda.zip . && \
  cd .. && zip -q docdb_lambda.zip docdb_function.py && \
  rm -rf ./package
"

echo -e "\n👉 [2/4] Provisioning / Updating Lambda Functions via AWS API..."

run_aws lambda create-function \
  --function-name AddNumbersLambda \
  --runtime python3.10 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler add_function.lambda_handler \
  --zip-file fileb://"$TEMP_DIR/add_lambda.zip" >/dev/null 2>&1 || \
run_aws lambda update-function-code \
  --function-name AddNumbersLambda \
  --zip-file fileb://"$TEMP_DIR/add_lambda.zip" >/dev/null

run_aws lambda create-function \
  --function-name FetchDocDBLambda \
  --runtime python3.10 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler docdb_function.lambda_handler \
  --zip-file fileb://"$TEMP_DIR/docdb_lambda.zip" >/dev/null 2>&1 || \
run_aws lambda update-function-code \
  --function-name FetchDocDBLambda \
  --zip-file fileb://"$TEMP_DIR/docdb_lambda.zip" >/dev/null

# Define JSON payloads in variables for reuse and display
ADD_PAYLOAD='{
  "num1": 15,
  "num2": 27
}'

DOCDB_PAYLOAD='{
  "host": "local-mongo-cluster",
  "port": 27017,
  "username": "admin",
  "password": "password123",
  "database": "test_docdb",
  "collection": "users"
}'

echo -e "\n👉 [3/4] Invoking Lambda 1: Addition Test..."
echo "📋 Event Payload (Copy for UI testing):"
echo "$ADD_PAYLOAD"

run_aws lambda invoke \
  --function-name AddNumbersLambda \
  --payload "$ADD_PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  "$TEMP_DIR/add_output.json" >/dev/null

echo -e "\nResult:"
cat "$TEMP_DIR/add_output.json"
echo -e "\n"

echo -e "👉 [4/4] Invoking Lambda 2: DocumentDB Data Fetch Test..."
echo "📋 Event Payload (Copy for UI testing):"
echo "$DOCDB_PAYLOAD"

run_aws lambda invoke \
  --function-name FetchDocDBLambda \
  --payload "$DOCDB_PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  "$TEMP_DIR/docdb_output.json" >/dev/null

echo -e "\nResult:"
cat "$TEMP_DIR/docdb_output.json"
echo -e "\n"