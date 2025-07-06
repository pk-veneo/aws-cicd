# 🚀 DEV Environment Deployment Guide

## 🎯 **Step 1: Deploy to DEV First**

This guide will help you deploy your serverless application to the **DEV environment** first, then you can proceed to QA and PROD.

---

## 📋 Prerequisites

### **Required:**
- ✅ AWS CLI installed and configured
- ✅ AWS SAM CLI installed
- ✅ GitHub account
- ✅ DEV AWS Account credentials

### **Get Your DEV AWS Credentials:**
- **Access Key ID:** `AKIA...`
- **Secret Access Key:** `...`
- **Region:** `ap-south-1`
- **Account ID:** `123456789012` (get this from AWS console)

---

## 🏗️ Step 1: Deploy Infrastructure to DEV

### **1.1 Configure AWS CLI for DEV Account**

```bash
# Configure AWS CLI for DEV account
aws configure set aws_access_key_id YOUR_DEV_ACCESS_KEY_ID
aws configure set aws_secret_access_key YOUR_DEV_SECRET_ACCESS_KEY
aws configure set region ap-south-1
aws configure set output json
```

### **1.2 Verify DEV Account Access**

```bash
# Verify you're connected to the right account
aws sts get-caller-identity

# Should show your DEV account ID
```

### **1.3 Deploy to DEV Environment**

```bash
# Deploy serverless infrastructure to DEV
sam deploy \
  --template-file template.yaml \
  --stack-name ServerlessEnterpriseStack-dev \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=dev \
    GitHubOrg=your-github-org \
    GitHubRepo=your-repo-name \
  --no-confirm-changeset \
  --no-fail-on-empty-changeset
```

**Expected Output:**
```
Deploying with following values
===============================
Stack name                   : ServerlessEnterpriseStack-dev
Region                       : ap-south-1
Confirm changeset            : False
Disable rollback             : False
Deployment s3 bucket         : aws-sam-cli-managed-default-samclisourcebucket-XXXXXXXXXXXX
Capabilities                 : ["CAPABILITY_NAMED_IAM"]
Parameter overrides          : {'Environment': 'dev', 'GitHubOrg': 'your-github-org', 'GitHubRepo': 'your-repo-name'}
Signing Profiles             : {}

Initiating deployment
====================
...
```

---

## ✅ Step 2: Verify DEV Deployment

### **2.1 Check CloudFormation Stack**

```bash
# Check if stack was created successfully
aws cloudformation describe-stacks \
  --stack-name ServerlessEnterpriseStack-dev \
  --query 'Stacks[0].StackStatus' \
  --output text

# Should return: CREATE_COMPLETE
```

### **2.2 List Created Resources**

```bash
# List Lambda functions
aws lambda list-functions \
  --query 'Functions[?contains(FunctionName, `dev`)].[FunctionName,Runtime]' \
  --output table

# List API Gateway
aws apigateway get-rest-apis \
  --query 'items[?contains(name, `dev`)].[name,id]' \
  --output table

# List S3 buckets
aws s3 ls | grep lambda-artifacts-dev

# List IAM roles
aws iam list-roles \
  --query 'Roles[?contains(RoleName, `dev`)].[RoleName]' \
  --output table
```

### **2.3 Get API Gateway URL**

```bash
# Get the API Gateway URL for DEV
aws cloudformation describe-stacks \
  --stack-name ServerlessEnterpriseStack-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text
```

**Expected Output:**
```
https://xxxxxxxxxx.execute-api.ap-south-1.amazonaws.com/dev/
```

### **2.4 Test DEV API Endpoints**

```bash
# Test the enterprise endpoint
curl https://your-dev-api-url/api/enterprise

# Test the workday endpoint
curl -X POST https://your-dev-api-url/api/workday \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

---

## 🌐 Step 3: GitHub Repository Setup

### **3.1 Create GitHub Repository**

1. Go to [GitHub.com](https://github.com)
2. Click **"New repository"**
3. Name: `your-repo-name`
4. Make it **Private**
5. Click **"Create repository"**

### **3.2 Push Your Code**

```bash
# Clone the repository
git clone https://github.com/your-org/your-repo-name.git
cd your-repo-name

# Copy all your project files
# (template.yaml, src/, .github/, etc.)

# Add and commit
git add .
git commit -m "Initial serverless setup for DEV"

# Push to main branch
git push origin main
```

### **3.3 Create DEV Branch**

```bash
# Create dev branch
git checkout -b dev
git push origin dev
```

---

## ⚙️ Step 4: Configure GitHub Variables

### **4.1 Add Repository Variables**

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **Variables** tab
3. Add these variables:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `DEV_ACCOUNT_ID` | `123456789012` | Your DEV AWS Account ID |
| `DEV_ROLE` | `GitHubActionsRole-dev` | DEV IAM Role name |
| `GITHUB_ORG` | `your-github-org` | Your GitHub organization |
| `GITHUB_REPO` | `your-repo-name` | Your repository name |

**Note:** We'll add QA and PROD variables later.

---

## 🛡️ Step 5: Create GitHub Environment

### **5.1 Create DEV Environment**

1. Go to your repository → **Settings** → **Environments**
2. Click **"New environment"**
3. **Environment name:** `dev`
4. **Protection rules:** None (for now)
5. Click **"Configure environment"**

---

## 🧪 Step 6: Test DEV Pipeline

### **6.1 Test DEV Deployment**

```bash
# Make a small change to test
echo "# DEV Environment Test" >> README.md
git add README.md
git commit -m "Test DEV deployment"
git push origin dev
```

### **6.2 Monitor Pipeline**

1. Go to your repository → **Actions** tab
2. Watch the pipeline run
3. Verify:
   - ✅ Tests pass
   - ✅ Build succeeds
   - ✅ Deployment to DEV works
   - ✅ API endpoints respond

---

## ✅ Step 7: Verify Everything Works

### **7.1 Check GitHub Actions**

- ✅ **Pipeline runs** when you push to `dev`
- ✅ **Deployment succeeds** to DEV environment
- ✅ **API tests pass**

### **7.2 Check AWS Resources**

```bash
# Verify all resources are created
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-dev

# Check Lambda functions
aws lambda list-functions --query 'Functions[?contains(FunctionName, `dev`)]'

# Check API Gateway
aws apigateway get-rest-apis --query 'items[?contains(name, `dev`)]'
```

### **7.3 Test API Endpoints**

```bash
# Get API URL
DEV_API_URL=$(aws cloudformation describe-stacks \
  --stack-name ServerlessEnterpriseStack-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text)

# Test endpoints
curl $DEV_API_URL/api/enterprise
curl -X POST $DEV_API_URL/api/workday -H "Content-Type: application/json" -d '{"test": true}'
```

---

## 🎉 Success Checklist

### **✅ DEV Environment:**
- ✅ Infrastructure deployed to DEV AWS account
- ✅ Lambda functions created (`MyEnterpriseLambda-dev`, `WorkdayAPILambda-dev`)
- ✅ API Gateway created (`EnterpriseAPI-dev`)
- ✅ S3 bucket created (`lambda-artifacts-dev-{ACCOUNT_ID}`)
- ✅ IAM roles created (`LambdaExecutionRole-dev`, `GitHubActionsRole-dev`)
- ✅ GitHub repository configured
- ✅ Pipeline tested and working
- ✅ API endpoints responding

---

## 🚀 Next Steps

Once DEV is working perfectly:

1. **Deploy to QA** (follow similar steps)
2. **Deploy to PROD** (follow similar steps)
3. **Set up branch protection** rules
4. **Configure monitoring** and alerts

---

## 🚨 Troubleshooting DEV

### **Deployment Fails:**
```bash
# Check CloudFormation events
aws cloudformation describe-stack-events \
  --stack-name ServerlessEnterpriseStack-dev
```

### **Pipeline Fails:**
1. Check GitHub Actions logs
2. Verify repository variables
3. Check AWS credentials

### **API Not Responding:**
```bash
# Check Lambda logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/dev"

# Check API Gateway
aws apigateway get-rest-apis
```

---

**🎉 Congratulations! Your DEV environment is ready!**

Once DEV is working perfectly, you can proceed to QA and PROD environments. 