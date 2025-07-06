#!/bin/bash

# Serverless Enterprise Lambda Deployment Script
# Usage: ./deploy.sh [dev|qa|prod]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ $# -eq 0 ]; then
    print_error "Please specify environment: dev, qa, or prod"
    echo "Usage: ./deploy.sh [dev|qa|prod]"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|qa|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Valid environments: dev, qa, prod"
    exit 1
fi

print_status "Deploying to $ENVIRONMENT environment..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    print_error "AWS SAM CLI is not installed. Please install it first."
    echo "Installation guide: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
    exit 1
fi

# Check if template.yaml exists
if [ ! -f "template.yaml" ]; then
    print_error "template.yaml not found in current directory"
    exit 1
fi

# Build the application
print_status "Building SAM application..."
sam build --template-file template.yaml
print_success "Build completed"

# Deploy the application
print_status "Deploying to AWS..."
sam deploy \
    --template-file template.yaml \
    --stack-name "ServerlessEnterpriseStack-$ENVIRONMENT" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        Environment=$ENVIRONMENT \
        GitHubOrg=your-org \
        GitHubRepo=your-repo \
    --no-confirm-changeset \
    --no-fail-on-empty-changeset

print_success "Deployment completed!"

# Get deployment outputs
print_status "Getting deployment outputs..."
API_URL=$(aws cloudformation describe-stacks \
    --stack-name "ServerlessEnterpriseStack-$ENVIRONMENT" \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
    --output text)

if [ ! -z "$API_URL" ]; then
    print_success "API Gateway URL: $API_URL"
    echo ""
    print_status "Test your API endpoints:"
    echo "  GET  $API_URL/api/enterprise"
    echo "  POST $API_URL/api/workday"
else
    print_warning "Could not retrieve API Gateway URL"
fi

# Test the API endpoints
print_status "Testing API endpoints..."
if [ ! -z "$API_URL" ]; then
    # Test enterprise endpoint
    if curl -f -s "$API_URL/api/enterprise" > /dev/null; then
        print_success "Enterprise endpoint is working"
    else
        print_warning "Enterprise endpoint test failed"
    fi
    
    # Test workday endpoint
    if curl -f -s -X POST "$API_URL/api/workday" \
        -H "Content-Type: application/json" \
        -d '{"test": true}' > /dev/null; then
        print_success "Workday endpoint is working"
    else
        print_warning "Workday endpoint test failed"
    fi
fi

print_success "Deployment to $ENVIRONMENT completed successfully!"
echo ""
print_status "Next steps:"
echo "  1. Update GitHub repository variables"
echo "  2. Push to the appropriate branch to trigger CI/CD"
echo "  3. Monitor logs in CloudWatch"
echo "  4. Set up monitoring and alerts" 