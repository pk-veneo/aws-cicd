# Multiple Lambda Functions Management Guide

## 🏗️ **How to Add New Lambda Functions**

### **Step 1: Create Your Lambda Function**
Add your new Lambda function file to the `src/` directory:

```python
# src/your_new_function.py
def lambda_handler(event, context):
    # Your Lambda function code here
    return {
        'statusCode': 200,
        'body': 'Your function response'
    }
```

### **Step 2: Update CloudFormation Template**
Add your new Lambda function to `lambda-cfn.yaml`:

```yaml
YourNewLambda:
  Type: AWS::Lambda::Function
  Properties:
    FunctionName: YourNewLambda
    Handler: your_new_function.lambda_handler  # filename.function_name
    Role: !Ref LambdaRoleArn
    Runtime: python3.11
    Code:
      S3Bucket: !Ref S3Bucket
      S3Key: !Ref S3Key
    Environment:
      Variables:
        DEPLOYMENT_TIMESTAMP: !Ref DeploymentTimestamp
```

### **Step 3: Update Test Script (Optional)**
Add your function to `test_lambda.py`:

```python
# Test your new function
your_function_success = test_lambda_function(
    'YourNewLambda', 
    'expected message in response'
)
```

### **Step 4: Deploy**
```bash
git add .
git commit -m "Add new Lambda function: YourNewLambda"
git push origin main
```

## 📁 **File Structure**
```
src/
├── lambda_function.py      # Original function
├── workday_api.py         # Workday API function
├── your_new_function.py   # Your new function
└── shared_utils.py        # Shared utilities (optional)
```

## 🔧 **Best Practices**

### **1. Naming Convention**
- **Files**: `snake_case.py` (e.g., `workday_api.py`)
- **Functions**: `PascalCase` (e.g., `WorkdayAPILambda`)
- **Handlers**: `filename.function_name` (e.g., `workday_api.lambda_handler`)

### **2. Shared Code**
Create `src/shared_utils.py` for common functionality:

```python
# src/shared_utils.py
import json

def create_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body)
    }
```

### **3. Environment Variables**
Use environment variables for configuration:

```yaml
Environment:
  Variables:
    API_ENDPOINT: "https://api.example.com"
    DEBUG_MODE: "false"
```

### **4. Dependencies**
Add new dependencies to `requirements.txt`:

```txt
requests==2.31.0
boto3==1.34.0
pandas==2.1.0  # Add new dependencies here
```

## 🚀 **Deployment Process**

1. **All functions are deployed together** when you push to main/dev
2. **Same S3 package** contains all Lambda functions
3. **CloudFormation** creates/updates all functions in parallel
4. **Versioned deployments** ensure all functions get updated

## 🧪 **Testing Multiple Functions**

```bash
# Test all functions
python test_lambda.py

# Test specific function
python -c "
import boto3
response = boto3.client('lambda').invoke(
    FunctionName='WorkdayAPILambda',
    InvocationType='RequestResponse'
)
print(response['Payload'].read())
"
```

## 📊 **Monitoring**

- **CloudWatch Logs**: Each function has its own log group
- **Metrics**: Monitor invocations, errors, duration per function
- **Alarms**: Set up alarms for errors or high latency

## 🔄 **Adding More Functions**

To add another function (e.g., `email_service.py`):

1. Create `src/email_service.py`
2. Add `EmailServiceLambda` to `lambda-cfn.yaml`
3. Update `test_lambda.py` if needed
4. Push to deploy

## ⚠️ **Important Notes**

- **All functions share the same IAM role** (LambdaExecutionRole)
- **All functions use the same runtime** (python3.11)
- **All functions are deployed together** - you can't deploy individual functions
- **S3 package contains all code** - keep functions lightweight

## 🎯 **Example: Adding a Third Function**

```python
# src/data_processor.py
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Data processing completed',
            'processed_records': 100
        })
    }
```

Add to `lambda-cfn.yaml`:
```yaml
DataProcessorLambda:
  Type: AWS::Lambda::Function
  Properties:
    FunctionName: DataProcessorLambda
    Handler: data_processor.lambda_handler
    Role: !Ref LambdaRoleArn
    Runtime: python3.11
    Code:
      S3Bucket: !Ref S3Bucket
      S3Key: !Ref S3Key
    Environment:
      Variables:
        DEPLOYMENT_TIMESTAMP: !Ref DeploymentTimestamp
```

That's it! Your new function will be deployed with the next push. 🚀 