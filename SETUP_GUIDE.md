# 🚀 Complete Setup Guide: AWS + GitHub

## 📋 Prerequisites

### **Required Tools:**
- ✅ AWS CLI installed and configured
- ✅ Git installed
- ✅ GitHub account
- ✅ AWS SAM CLI (optional, for local testing)

### **Required AWS Accounts:**
- ✅ **DEV AWS Account** (Account ID needed)
- ✅ **QA AWS Account** (Account ID needed)  
- ✅ **PROD AWS Account** (Account ID needed)

---

## 🏗️ Step 1: AWS Infrastructure Setup

### **1.1 Deploy AWS Infrastructure**

First, deploy the serverless infrastructure to all three AWS accounts:

```bash
# Deploy to DEV account
aws configure set aws_access_key_id YOUR_DEV_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_DEV_SECRET_KEY
aws configure set region ap-south-1

sam deploy \
  --template-file template.yaml \
  --stack-name ServerlessEnterpriseStack-dev \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=dev \
    GitHubOrg=your-github-org \
    GitHubRepo=your-repo-name \
  --no-confirm-changeset
```

```bash
# Deploy to QA account
aws configure set aws_access_key_id YOUR_QA_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_QA_SECRET_KEY
aws configure set region ap-south-1

sam deploy \
  --template-file template.yaml \
  --stack-name ServerlessEnterpriseStack-qa \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=qa \
    GitHubOrg=your-github-org \
    GitHubRepo=your-repo-name \
  --no-confirm-changeset
```

```bash
# Deploy to PROD account
aws configure set aws_access_key_id YOUR_PROD_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_PROD_SECRET_KEY
aws configure set region ap-south-1

sam deploy \
  --template-file template.yaml \
  --stack-name ServerlessEnterpriseStack-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Environment=prod \
    GitHubOrg=your-github-org \
    GitHubRepo=your-repo-name \
  --no-confirm-changeset
```

### **1.2 Get AWS Account IDs**

After deployment, get your AWS account IDs:

```bash
# Get account ID for each environment
aws sts get-caller-identity --query Account --output text
```

**Note down these account IDs:**
- **DEV Account ID:** `123456789012`
- **QA Account ID:** `123456789013`
- **PROD Account ID:** `123456789014`

### **1.3 Get IAM Role ARNs**

Get the GitHub Actions role ARNs from each account:

```bash
# For DEV account
aws iam get-role --role-name GitHubActionsRole-dev --query Role.Arn --output text

# For QA account  
aws iam get-role --role-name GitHubActionsRole-qa --query Role.Arn --output text

# For PROD account
aws iam get-role --role-name GitHubActionsRole-prod --query Role.Arn --output text
```

---

## 🌐 Step 2: GitHub Repository Setup

### **2.1 Create GitHub Repository**

1. Go to [GitHub.com](https://github.com)
2. Click **"New repository"**
3. Name it: `your-repo-name`
4. Make it **Private** (recommended)
5. Click **"Create repository"**

### **2.2 Push Your Code**

```bash
# Clone your repository
git clone https://github.com/your-org/your-repo-name.git
cd your-repo-name

# Copy all your project files
# (template.yaml, src/, .github/, etc.)

# Add and commit files
git add .
git commit -m "Initial serverless setup"

# Push to main branch
git push origin main
```

### **2.3 Create Environment Branches**

```bash
# Create dev branch
git checkout -b dev
git push origin dev

# Create qa branch
git checkout -b qa
git push origin qa

# Go back to main
git checkout main
```

---

## ⚙️ Step 3: GitHub Repository Variables

### **3.1 Add Repository Variables**

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **Variables** tab
4. Add these variables:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `DEV_ACCOUNT_ID` | `123456789012` | Your DEV AWS Account ID |
| `DEV_ROLE` | `GitHubActionsRole-dev` | DEV IAM Role name |
| `QA_ACCOUNT_ID` | `123456789013` | Your QA AWS Account ID |
| `QA_ROLE` | `GitHubActionsRole-qa` | QA IAM Role name |
| `PROD_ACCOUNT_ID` | `123456789014` | Your PROD AWS Account ID |
| `PROD_ROLE` | `GitHubActionsRole-prod` | PROD IAM Role name |
| `GITHUB_ORG` | `your-github-org` | Your GitHub organization |
| `GITHUB_REPO` | `your-repo-name` | Your repository name |

### **3.2 Add Repository Secrets (if needed)**

If you need to store sensitive information:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | AWS Access Key (if not using OIDC) |
| `AWS_SECRET_ACCESS_KEY` | `...` | AWS Secret Key (if not using OIDC) |

---

## 🛡️ Step 4: GitHub Environments Setup

### **4.1 Create Environments**

1. Go to your repository → **Settings** → **Environments**
2. Click **"New environment"**

#### **Create `dev` environment:**
- **Environment name:** `dev`
- **Protection rules:** None (or optional)
- **Deployment branches:** `dev`

#### **Create `qa` environment:**
- **Environment name:** `qa`
- **Protection rules:** 
  - ✅ **Required reviewers** (add your team)
  - ✅ **Wait timer** (5 minutes)
- **Deployment branches:** `qa`

#### **Create `prod` environment:**
- **Environment name:** `prod`
- **Protection rules:**
  - ✅ **Required reviewers** (add senior team members)
  - ✅ **Wait timer** (10 minutes)
  - ✅ **Deployment branches:** `main`

---

## 🌿 Step 5: Branch Protection Rules

### **5.1 Set Up Branch Protection**

1. Go to your repository → **Settings** → **Branches**
2. Click **"Add rule"**

#### **For `main` branch (Production):**
- ✅ **Require a pull request before merging**
- ✅ **Require approvals** (2 reviewers minimum)
- ✅ **Dismiss stale PR approvals when new commits are pushed**
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**
- ✅ **Require linear history**
- ✅ **Require deployments to succeed before merging**

#### **For `qa` branch:**
- ✅ **Require a pull request before merging**
- ✅ **Require approvals** (1 reviewer minimum)
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**

#### **For `dev` branch:**
- ✅ **Require a pull request before merging**
- ✅ **Require status checks to pass before merging**

---

## 🧪 Step 6: Test the Setup

### **6.1 Test Dev Deployment**

```bash
# Make a small change to test
echo "# Test deployment" >> README.md
git add README.md
git commit -m "Test dev deployment"
git push origin dev
```

**Check:**
1. Go to **Actions** tab in GitHub
2. Watch the pipeline run
3. Verify deployment to DEV environment

### **6.2 Test QA Promotion**

```bash
# Create PR from dev to qa
git checkout qa
git merge dev
git push origin qa
```

**Check:**
1. Go to **Actions** tab
2. Watch QA deployment
3. Verify approval process

### **6.3 Test Production Deployment**

```bash
# Create PR from qa to main
git checkout main
git merge qa
git push origin main
```

**Check:**
1. Go to **Actions** tab
2. Watch PROD deployment
3. Verify senior approval process

---

## 🔍 Step 7: Verify AWS Resources

### **7.1 Check DEV Environment**

```bash
# Switch to DEV account
aws configure set aws_access_key_id YOUR_DEV_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_DEV_SECRET_KEY

# List resources
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-dev
aws lambda list-functions --query 'Functions[?contains(FunctionName, `dev`)]'
aws apigateway get-rest-apis --query 'items[?contains(name, `dev`)]'
```

### **7.2 Check QA Environment**

```bash
# Switch to QA account
aws configure set aws_access_key_id YOUR_QA_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_QA_SECRET_KEY

# List resources
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-qa
aws lambda list-functions --query 'Functions[?contains(FunctionName, `qa`)]'
aws apigateway get-rest-apis --query 'items[?contains(name, `qa`)]'
```

### **7.3 Check PROD Environment**

```bash
# Switch to PROD account
aws configure set aws_access_key_id YOUR_PROD_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_PROD_SECRET_KEY

# List resources
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-prod
aws lambda list-functions --query 'Functions[?contains(FunctionName, `prod`)]'
aws apigateway get-rest-apis --query 'items[?contains(name, `prod`)]'
```

---

## 🚨 Step 8: Troubleshooting

### **Common Issues:**

#### **Pipeline Fails on OIDC:**
```bash
# Check if OIDC provider exists
aws iam list-open-id-connect-providers

# Verify GitHub Actions role
aws iam get-role --role-name GitHubActionsRole-dev
```

#### **Deployment Fails:**
```bash
# Check CloudFormation events
aws cloudformation describe-stack-events \
  --stack-name ServerlessEnterpriseStack-dev
```

#### **API Tests Fail:**
```bash
# Get API Gateway URL
aws cloudformation describe-stacks \
  --stack-name ServerlessEnterpriseStack-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text
```

---

## ✅ Step 9: Success Checklist

### **AWS Setup:**
- ✅ Infrastructure deployed to all 3 accounts
- ✅ IAM roles created with proper permissions
- ✅ OIDC provider configured
- ✅ S3 buckets created with versioning
- ✅ Lambda functions deployed
- ✅ API Gateway created

### **GitHub Setup:**
- ✅ Repository created with all files
- ✅ Environment branches created (dev, qa, main)
- ✅ Repository variables configured
- ✅ Environments created with protection rules
- ✅ Branch protection rules configured
- ✅ Pipeline tested and working

### **Testing:**
- ✅ Dev deployment works
- ✅ QA promotion works with approval
- ✅ Prod deployment works with senior approval
- ✅ API endpoints responding
- ✅ All environments isolated

---

## 🎉 Congratulations!

Your **dev → qa → prod** serverless pipeline is now fully set up and ready for production use!

### **Next Steps:**
1. **Monitor deployments** in GitHub Actions
2. **Set up CloudWatch alerts** for each environment
3. **Configure custom domains** for API Gateway
4. **Add more Lambda functions** as needed
5. **Implement monitoring dashboards**

---

**🚀 Your serverless CI/CD pipeline is ready to scale!** 