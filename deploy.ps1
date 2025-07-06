# Serverless Enterprise Lambda Deployment Script for PowerShell
# Usage: .\deploy.ps1 [dev|qa|prod]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "qa", "prod")]
    [string]$Environment
)

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Status "Deploying to $Environment environment..."

# Check if AWS CLI is installed
try {
    $null = Get-Command aws -ErrorAction Stop
} catch {
    Write-Error "AWS CLI is not installed. Please install it first."
    exit 1
}

# Check if SAM CLI is installed
try {
    $null = Get-Command sam -ErrorAction Stop
} catch {
    Write-Error "AWS SAM CLI is not installed. Please install it first."
    Write-Host "Installation guide: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
    exit 1
}

# Check if template.yaml exists
if (-not (Test-Path "template.yaml")) {
    Write-Error "template.yaml not found in current directory"
    exit 1
}

# Build the application
Write-Status "Building SAM application..."
try {
    sam build --template-file template.yaml
    Write-Success "Build completed"
} catch {
    Write-Error "Build failed"
    exit 1
}

# Deploy the application
Write-Status "Deploying to AWS..."
try {
    sam deploy `
        --template-file template.yaml `
        --stack-name "ServerlessEnterpriseStack-$Environment" `
        --capabilities CAPABILITY_NAMED_IAM `
        --parameter-overrides "Environment=$Environment" `
        --no-confirm-changeset `
        --no-fail-on-empty-changeset
    
    Write-Success "Deployment completed!"
} catch {
    Write-Error "Deployment failed"
    exit 1
}

# Get deployment outputs
Write-Status "Getting deployment outputs..."
try {
    $API_URL = aws cloudformation describe-stacks `
        --stack-name "ServerlessEnterpriseStack-$Environment" `
        --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' `
        --output text

    if ($API_URL) {
        Write-Success "API Gateway URL: $API_URL"
        Write-Host ""
        Write-Status "Test your API endpoints:"
        Write-Host "  GET  $API_URL/api/enterprise"
        Write-Host "  POST $API_URL/api/workday"
    } else {
        Write-Warning "Could not retrieve API Gateway URL"
    }
} catch {
    Write-Warning "Could not retrieve deployment outputs"
}

# Test the API endpoints
Write-Status "Testing API endpoints..."
if ($API_URL) {
    # Test enterprise endpoint
    try {
        $response = Invoke-WebRequest -Uri "$API_URL/api/enterprise" -Method GET -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Success "Enterprise endpoint is working"
        } else {
            Write-Warning "Enterprise endpoint test failed"
        }
    } catch {
        Write-Warning "Enterprise endpoint test failed"
    }
    
    # Test workday endpoint
    try {
        $body = @{test=$true} | ConvertTo-Json
        $response = Invoke-WebRequest -Uri "$API_URL/api/workday" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Success "Workday endpoint is working"
        } else {
            Write-Warning "Workday endpoint test failed"
        }
    } catch {
        Write-Warning "Workday endpoint test failed"
    }
}

Write-Success "Deployment to $Environment completed successfully!"
Write-Host ""
Write-Status "Next steps:"
Write-Host "  1. Update GitHub repository variables"
Write-Host "  2. Push to the appropriate branch to trigger CI/CD"
Write-Host "  3. Monitor logs in CloudWatch"
Write-Host "  4. Set up monitoring and alerts" 