# Setup IAM Roles for GitHub Actions OIDC
# This script creates IAM roles for dev, qa, and prod environments

$ACCOUNT_ID = "898465023829"
$REPOSITORY = "pk-veneo/aws-cicd"

Write-Host "Setting up IAM roles for GitHub Actions OIDC..." -ForegroundColor Green

# Create trust policy
$trustPolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Principal = @{
                Federated = "arn:aws:iam::$ACCOUNT_ID`:oidc-provider/token.actions.githubusercontent.com"
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = @{
                StringLike = @{
                    "token.actions.githubusercontent.com:sub" = "repo:$REPOSITORY:*"
                }
            }
        }
    )
} | ConvertTo-Json -Depth 10

# Save trust policy to file
$trustPolicy | Out-File -FilePath "trust-policy.json" -Encoding UTF8

# Create roles for all environments
$environments = @("dev", "qa", "prod")

foreach ($env in $environments) {
    $roleName = "GitHubActionsRole-$env"
    
    Write-Host "Creating role: $roleName" -ForegroundColor Yellow
    
    try {
        # Create the role
        aws iam create-role --role-name $roleName --assume-role-policy-document file://trust-policy.json
        
        # Attach administrator policy
        aws iam attach-role-policy --role-name $roleName --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
        
        Write-Host "✅ Successfully created $roleName" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Role $roleName might already exist or there was an error" -ForegroundColor Yellow
    }
}

# Clean up
Remove-Item "trust-policy.json" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 IAM Roles setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Add these variables to your GitHub repository:" -ForegroundColor Cyan
Write-Host "   DEV_ACCOUNT_ID: $ACCOUNT_ID" -ForegroundColor White
Write-Host "   DEV_ROLE: GitHubActionsRole-dev" -ForegroundColor White
Write-Host "   QA_ACCOUNT_ID: $ACCOUNT_ID" -ForegroundColor White
Write-Host "   QA_ROLE: GitHubActionsRole-qa" -ForegroundColor White
Write-Host "   PROD_ACCOUNT_ID: $ACCOUNT_ID" -ForegroundColor White
Write-Host "   PROD_ROLE: GitHubActionsRole-prod" -ForegroundColor White
Write-Host ""
Write-Host "🔗 GitHub Repository: https://github.com/$REPOSITORY/settings/secrets/actions" -ForegroundColor Cyan 