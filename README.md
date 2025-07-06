# 🚀 Serverless Enterprise Lambda Application

A modern serverless application built with AWS SAM (Serverless Application Model) featuring Lambda functions, API Gateway, and automated CI/CD pipeline.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│   AWS SAM       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   AWS Lambda    │    │  API Gateway    │
                       │   Functions     │    │                 │
                       └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   S3 Bucket     │    │  CloudWatch     │
                       │   (Artifacts)   │    │  (Logs)         │
                       └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
AWS_CI_CD_Demo/
├── src/                          # Lambda function source code
│   ├── lambda_function.py        # Main enterprise Lambda handler
│   └── workday_api.py           # Workday API Lambda handler
├── template.yaml                 # AWS SAM template (main)
├── samconfig.toml               # SAM deployment configuration
├── local-test.py                # Local testing script
├── requirements.txt              # Python dependencies
├── .github/workflows/           # CI/CD workflows
│   └── deploy.yml               # Serverless deployment workflow
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** installed and configured
2. **AWS SAM CLI** installed
3. **Python 3.12** installed
4. **GitHub repository** with OIDC setup

### Local Development

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Build SAM application
python local-test.py build

# 3. Start local API (for testing)
python local-test.py api

# 4. Test specific function
python local-test.py test MyEnterpriseLambda
```

### Deploy to AWS

```bash
# Deploy to dev environment
sam deploy --config-env dev

# Deploy to qa environment  
sam deploy --config-env qa

# Deploy to prod environment
sam deploy --config-env prod
```

## 🔧 Configuration

### GitHub Repository Variables

Set these variables in your GitHub repository (Settings → Secrets and variables → Actions → Variables):

| Variable | Description | Example |
|----------|-------------|---------|
| `DEV_ACCOUNT_ID` | AWS Account ID for Dev | `123456789012` |
| `DEV_ROLE` | IAM Role for Dev | `GitHubActionsRole-dev` |
| `QA_ACCOUNT_ID` | AWS Account ID for QA | `123456789012` |
| `QA_ROLE` | IAM Role for QA | `GitHubActionsRole-qa` |
| `PROD_ACCOUNT_ID` | AWS Account ID for Prod | `123456789012` |
| `PROD_ROLE` | IAM Role for Prod | `GitHubActionsRole-prod` |
| `GITHUB_ORG` | GitHub organization | `your-org` |
| `GITHUB_REPO` | GitHub repository | `your-repo` |

### Environment Mapping

| Branch | Environment | Stack Name | API Gateway |
|--------|-------------|------------|-------------|
| `dev` | Development | `ServerlessEnterpriseStack-dev` | `EnterpriseAPI-dev` |
| `qa` | QA/Staging | `ServerlessEnterpriseStack-qa` | `EnterpriseAPI-qa` |
| `main` | Production | `ServerlessEnterpriseStack-prod` | `EnterpriseAPI-prod` |

## 🏗️ AWS Resources Created

### **Lambda Functions**
- **`MyEnterpriseLambda-{env}`** - Main enterprise function
  - HTTP endpoint: `GET /api/enterprise`
  - S3 trigger: File uploads to artifacts bucket
  - Runtime: Python 3.12

- **`WorkdayAPILambda-{env}`** - Workday API integration
  - HTTP endpoint: `POST /api/workday`
  - Scheduled trigger: Every hour
  - Runtime: Python 3.12

### **API Gateway**
- **`EnterpriseAPI-{env}`** - REST API with CORS enabled
- **Endpoints:**
  - `GET /api/enterprise` - Enterprise data
  - `POST /api/workday` - Workday API calls

### **Infrastructure**
- **S3 Bucket** - `lambda-artifacts-{env}-{account}`
- **IAM Roles** - Lambda execution and GitHub Actions
- **OIDC Provider** - GitHub Actions authentication
- **CloudWatch Logs** - Function logging

## 🔄 CI/CD Pipeline

### **Automatic Deployment**
1. **Push to `dev`** → Deploys to DEV environment
2. **Push to `qa`** → Deploys to QA environment  
3. **Push to `main`** → Deploys to PROD environment

### **Pipeline Steps**
1. **Checkout** - Get latest code
2. **Test** - Run Python tests
3. **Build** - SAM build application
4. **Deploy** - SAM deploy to AWS
5. **Test API** - Verify endpoints work
6. **Cleanup** - Remove old deployments

## 🧪 Testing

### **Local Testing**
```bash
# Test specific function
python local-test.py test MyEnterpriseLambda

# Start local API server
python local-test.py api

# Build application
python local-test.py build
```

### **API Testing**
```bash
# Test enterprise endpoint
curl https://your-api-gateway-url/api/enterprise

# Test workday endpoint
curl -X POST https://your-api-gateway-url/api/workday \
  -H "Content-Type: application/json" \
  -d '{"action": "get_employees"}'
```

## 📊 Monitoring

### **CloudWatch Logs**
- **Log Groups:**
  - `/aws/lambda/MyEnterpriseLambda-{env}`
  - `/aws/lambda/WorkdayAPILambda-{env}`

### **API Gateway Metrics**
- Request count
- Latency
- Error rates
- Cache hit/miss

### **Lambda Metrics**
- Invocation count
- Duration
- Error count
- Throttles

## 🔒 Security

### **IAM Roles**
- **Least privilege** access
- **OIDC authentication** for GitHub Actions
- **No static credentials** in code

### **S3 Security**
- **Versioning enabled**
- **Public access blocked**
- **Encryption at rest**

### **API Gateway**
- **CORS configured**
- **HTTPS only**
- **Request validation**

## 💰 Cost Optimization

### **Lambda**
- **Pay per request** (no idle costs)
- **Automatic scaling**
- **Memory optimization**

### **API Gateway**
- **Pay per API call**
- **Caching for performance**

### **S3**
- **Lifecycle policies** for old artifacts
- **Intelligent tiering**

## 🚀 Benefits of Serverless

### **✅ Advantages**
- **No server management** - AWS handles infrastructure
- **Automatic scaling** - Handles traffic spikes
- **Pay per use** - Only pay for actual usage
- **Built-in security** - IAM, VPC, encryption
- **Faster development** - Focus on business logic
- **Event-driven** - Triggers from various sources

### **🔄 Event Sources**
- **API Gateway** - HTTP requests
- **S3** - File uploads
- **CloudWatch Events** - Scheduled tasks
- **SQS/SNS** - Message queues
- **DynamoDB** - Database changes

## 📚 Next Steps

1. **Add more Lambda functions** for different business logic
2. **Implement DynamoDB** for data persistence
3. **Add authentication** with Cognito
4. **Set up monitoring** with CloudWatch dashboards
5. **Add custom domains** for API Gateway
6. **Implement blue-green deployments**

---

**🎉 Your application is now fully serverless!** 

The architecture automatically scales, handles events, and provides a modern development experience with local testing capabilities. 