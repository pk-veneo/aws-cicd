#!/bin/bash

# Create IAM Role for GitHub Actions
# Usage: ./create-github-actions-role.sh [dev|qa|prod]

ENVIRONMENT=${1:-dev}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-south-1"

echo "Creating GitHub Actions role for $ENVIRONMENT environment..."

# Create the trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPOSITORY:-your-org/your-repo}:*"
        }
      }
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name "GitHubActionsRole-${ENVIRONMENT}" \
  --assume-role-policy-document file://trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name "GitHubActionsRole-${ENVIRONMENT}" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "✅ Created GitHub Actions role: GitHubActionsRole-${ENVIRONMENT}"
echo "📝 Add this to your GitHub repository variables:"
echo "   DEV_ROLE: GitHubActionsRole-${ENVIRONMENT}"
echo "   DEV_ACCOUNT_ID: ${ACCOUNT_ID}"

# Clean up
rm trust-policy.json 