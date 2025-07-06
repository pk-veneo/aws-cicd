# 🌿 Branch Protection & Deployment Workflow

## Overview
This guide explains how to set up branch protection rules and deployment environments to ensure your **dev → qa → prod** workflow works smoothly.

## 🔄 Workflow Process

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   dev       │───▶│   qa        │───▶│   main      │
│   branch    │    │   branch    │    │   (prod)    │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Dev       │    │   QA        │    │   Prod      │
│   AWS       │    │   AWS       │    │   AWS       │
│   Account   │    │   Account   │    │   Account   │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 🛡️ Branch Protection Setup

### **1. GitHub Repository Settings**

Go to your repository → **Settings** → **Branches** → **Add rule**

#### **For `main` branch (Production):**
- ✅ **Require a pull request before merging**
- ✅ **Require approvals** (2 reviewers minimum)
- ✅ **Dismiss stale PR approvals when new commits are pushed**
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**
- ✅ **Restrict pushes that create files that use the gitattributes pattern**
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

## 🌍 Environment Setup

### **1. Create GitHub Environments**

Go to your repository → **Settings** → **Environments** → **New environment**

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

## 🔧 Required GitHub Variables

### **Repository Variables** (Settings → Secrets and variables → Actions → Variables)

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

## 🚀 Deployment Workflow

### **Step 1: Development**
```bash
# Create feature branch from dev
git checkout dev
git pull origin dev
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to feature branch
git push origin feature/new-feature

# Create PR to dev branch
# → GitHub will run tests
# → Merge to dev when approved
```

### **Step 2: Dev Deployment**
```bash
# When PR is merged to dev
# → Automatic deployment to DEV environment
# → Tests run automatically
# → API endpoints tested
```

### **Step 3: QA Promotion**
```bash
# Create PR from dev to qa
git checkout qa
git pull origin qa
git merge dev
git push origin qa

# → Requires approval
# → Deploys to QA environment
# → Tests run automatically
```

### **Step 4: Production Deployment**
```bash
# Create PR from qa to main
git checkout main
git pull origin main
git merge qa
git push origin main

# → Requires senior approval
# → Deploys to PROD environment
# → Tests run automatically
```

## ✅ Pipeline Features

### **Automatic Testing**
- ✅ **Unit tests** run on every PR
- ✅ **SAM build** validation
- ✅ **API endpoint testing** after deployment
- ✅ **Environment-specific** testing

### **Approval Gates**
- ✅ **Dev** → No approval required (automatic)
- ✅ **QA** → 1 reviewer approval required
- ✅ **Prod** → 2 senior reviewer approvals required

### **Safety Features**
- ✅ **Wait timers** (5min QA, 10min Prod)
- ✅ **Status checks** must pass
- ✅ **Branches must be up to date**
- ✅ **Linear history** enforced

## 🔍 Monitoring & Rollback

### **Deployment Monitoring**
- **CloudWatch Logs** for each environment
- **API Gateway metrics** and alerts
- **Lambda function metrics**
- **Error tracking** and notifications

### **Rollback Strategy**
```bash
# If deployment fails, rollback to previous version
git revert HEAD
git push origin main

# Or use SAM rollback
sam rollback --stack-name ServerlessEnterpriseStack-prod
```

## 🎯 Best Practices

### **1. Code Quality**
- ✅ **Run tests locally** before pushing
- ✅ **Code review** for all changes
- ✅ **Follow coding standards**
- ✅ **Update documentation**

### **2. Deployment Safety**
- ✅ **Test in dev first**
- ✅ **Validate in qa before prod**
- ✅ **Monitor deployments**
- ✅ **Have rollback plan**

### **3. Communication**
- ✅ **Notify team** of deployments
- ✅ **Document changes**
- ✅ **Update release notes**
- ✅ **Monitor feedback**

## 🚨 Troubleshooting

### **Common Issues**

#### **Pipeline Fails on Tests**
```bash
# Run tests locally first
python -m pytest tests/ -v
```

#### **Deployment Fails**
```bash
# Check CloudFormation events
aws cloudformation describe-stack-events \
  --stack-name ServerlessEnterpriseStack-dev
```

#### **API Tests Fail**
```bash
# Check API Gateway logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda"
```

---

**🎉 Your dev → qa → prod workflow is now fully automated and secure!**

The pipeline ensures code quality, requires approvals, and provides safe deployments across all environments. 