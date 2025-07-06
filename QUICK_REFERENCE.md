# 🚀 Quick Reference Card

## 📋 Essential Commands

### **AWS Setup (One-time)**
```bash
# Deploy to DEV
sam deploy --template-file template.yaml --stack-name ServerlessEnterpriseStack-dev --capabilities CAPABILITY_NAMED_IAM --parameter-overrides Environment=dev GitHubOrg=your-org GitHubRepo=your-repo

# Deploy to QA  
sam deploy --template-file template.yaml --stack-name ServerlessEnterpriseStack-qa --capabilities CAPABILITY_NAMED_IAM --parameter-overrides Environment=qa GitHubOrg=your-org GitHubRepo=your-repo

# Deploy to PROD
sam deploy --template-file template.yaml --stack-name ServerlessEnterpriseStack-prod --capabilities CAPABILITY_NAMED_IAM --parameter-overrides Environment=prod GitHubOrg=your-org GitHubRepo=your-repo
```

### **Get Account IDs**
```bash
aws sts get-caller-identity --query Account --output text
```

### **GitHub Repository Variables**
| Variable | Value |
|----------|-------|
| `DEV_ACCOUNT_ID` | Your DEV AWS Account ID |
| `DEV_ROLE` | `GitHubActionsRole-dev` |
| `QA_ACCOUNT_ID` | Your QA AWS Account ID |
| `QA_ROLE` | `GitHubActionsRole-qa` |
| `PROD_ACCOUNT_ID` | Your PROD AWS Account ID |
| `PROD_ROLE` | `GitHubActionsRole-prod` |
| `GITHUB_ORG` | Your GitHub organization |
| `GITHUB_REPO` | Your repository name |

### **Daily Workflow**
```bash
# 1. Create feature branch
git checkout dev
git pull origin dev
git checkout -b feature/new-feature

# 2. Make changes and commit
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# 3. Create PR to dev branch
# → Automatic deployment to DEV

# 4. Merge dev to qa
git checkout qa
git merge dev
git push origin qa
# → Requires approval → Deploys to QA

# 5. Merge qa to main
git checkout main
git merge qa
git push origin main
# → Requires senior approval → Deploys to PROD
```

### **Check Deployments**
```bash
# Check DEV resources
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-dev

# Check QA resources
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-qa

# Check PROD resources
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-prod
```

### **Get API URLs**
```bash
# DEV API URL
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-dev --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' --output text

# QA API URL
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-qa --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' --output text

# PROD API URL
aws cloudformation describe-stacks --stack-name ServerlessEnterpriseStack-prod --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' --output text
```

### **Test API Endpoints**
```bash
# Test DEV API
curl https://your-dev-api-url/api/enterprise

# Test QA API
curl https://your-qa-api-url/api/enterprise

# Test PROD API
curl https://your-prod-api-url/api/enterprise
```

## 🔧 Troubleshooting

### **Pipeline Fails**
1. Check GitHub Actions logs
2. Verify repository variables
3. Check AWS credentials and permissions

### **Deployment Fails**
```bash
# Check CloudFormation events
aws cloudformation describe-stack-events --stack-name ServerlessEnterpriseStack-dev
```

### **API Not Responding**
```bash
# Check Lambda logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda"

# Check API Gateway
aws apigateway get-rest-apis
```

## 📊 Monitoring

### **CloudWatch Logs**
- `/aws/lambda/MyEnterpriseLambda-dev`
- `/aws/lambda/WorkdayAPILambda-dev`
- `/aws/lambda/MyEnterpriseLambda-qa`
- `/aws/lambda/WorkdayAPILambda-qa`
- `/aws/lambda/MyEnterpriseLambda-prod`
- `/aws/lambda/WorkdayAPILambda-prod`

### **GitHub Actions**
- Go to repository → Actions tab
- Monitor deployment status
- Check approval requirements

## 🎯 Branch Strategy

| Branch | Environment | Approval Required |
|--------|-------------|------------------|
| `dev` | DEV | ❌ No |
| `qa` | QA | ✅ Yes (1 reviewer) |
| `main` | PROD | ✅ Yes (2 senior reviewers) |

## 🚨 Emergency Rollback

```bash
# Rollback to previous version
git revert HEAD
git push origin main

# Or use SAM rollback
sam rollback --stack-name ServerlessEnterpriseStack-prod
```

---

**🎉 Your serverless pipeline is ready!** 