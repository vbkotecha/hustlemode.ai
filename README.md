# Infrastructure Setup Guide

This repository contains Terraform configurations for setting up the infrastructure for Hustlemode.ai, including a PostgreSQL RDS instance and associated networking components.

## One-Time Setup Steps

### 1. Install Required Tools

#### Using Homebrew (macOS)

### 2. AWS Account Setup
1. Create an AWS account if you don't have one
2. Create an IAM user with programmatic access
3. Save the access key and secret key securely

### 3. Initial AWS Resources
Run these commands once to set up Terraform state management:
```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
    --bucket hustlemode-terraform-state \
    --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2

# Enable bucket versioning
aws s3api put-bucket-versioning \
    --bucket hustlemode-terraform-state \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name hustlemode-terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### 4. Initial Configuration
1. Clone this repository
2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edit `terraform.tfvars` with your values:
   ```hcl
   environment     = "dev"
   aws_region      = "us-west-2"
   aws_access_key  = "YOUR_ACCESS_KEY"
   aws_secret_key  = "YOUR_SECRET_KEY"
   db_password     = "YOUR_SECURE_PASSWORD"
   ```

### 5. First-Time Terraform Setup
```bash
# Initialize Terraform with backend configuration
terraform init \
    -backend-config="bucket=hustlemode-terraform-state" \
    -backend-config="key=infrastructure/terraform.tfstate" \
    -backend-config="region=us-west-2"
```

## Regular Operations

### Deploying Changes
1. Review planned changes:
   ```bash
   terraform plan
   ```

2. Apply changes:
   ```bash
   terraform apply
   ```

### Accessing the Database
The RDS instance can be accessed using:
- Host: Available in AWS Console or terraform outputs
- Port: 5432
- Database: discipline_app
- Username: app_user
- Password: As specified in terraform.tfvars

### Common Tasks
1. View resources:
   ```bash
   terraform show
   ```

2. Destroy infrastructure (caution!):
   ```bash
   terraform destroy
   ```

## Infrastructure Components

Current MVP Setup (~$13/month):
- RDS PostgreSQL (db.t3.micro)
- 10GB storage
- Single AZ deployment
- Basic security groups
- Default VPC networking

## Cost Notes
- Current configuration optimized for MVP/side project
- No high availability or automated backups
- Can be scaled up later if needed
- Main cost is the RDS instance (~$12.24/month)

## Troubleshooting

### Connection Issues
1. Check security group rules
2. Verify AWS credentials
3. Confirm database endpoint
4. Test network connectivity

### Common Errors
1. **Terraform state lock**: Wait a few minutes and try again
2. **Connection timeout**: Check security groups
3. **Authentication failed**: Verify credentials in terraform.tfvars

## Architecture Overview

The infrastructure is designed with the following principles:
- Security-first approach with strict access controls
- High availability across multiple availability zones
- Automated backup and recovery procedures
- Scalable resource allocation
- Comprehensive monitoring and logging

## Prerequisites

1. AWS account with the following IAM permissions:
   - Create an IAM user for Terraform:
     1. Log into the AWS Console (https://console.aws.amazon.com)
     2. Go to IAM service
     3. Click "Users" in the left sidebar
     4. Click "Create user"
     5. Enter a name like "terraform-admin"
     6. Click "Next"
     7. Select "Attach policies directly"
     8. Search for and attach these policies:
        - AmazonRDSFullAccess
        - AmazonVPCFullAccess 
        - AmazonS3FullAccess
        - AmazonDynamoDBFullAccess
        - IAMFullAccess
        - AWSLambda_FullAccess
     9. Click "Next" and then "Create user"
     10. On the user details page, click "Security credentials"
     11. Click "Create access key"
     12. Choose "Command Line Interface (CLI)"
     13. Click through the prompts
     14. **Important**: Save the Access Key ID and Secret Access Key shown - you'll need these later and won't be able to see the secret key again

   Note: For production environments, you should create more restrictive custom policies rather than using the *FullAccess policies. Consult with your security team for proper permission scoping.

## Production Considerations

### Security
- Enable AWS CloudTrail for API activity logging
- Use AWS Config for resource compliance
- Implement AWS GuardDuty for threat detection
- Enable VPC Flow Logs
- Use AWS WAF for web application protection

### Monitoring
- Set up CloudWatch Alarms for:
  - RDS CPU utilization
  - Storage space
  - Connection count
  - Replica lag
- Configure SNS notifications for critical alerts

### Backup and Recovery
- RDS automated backups are enabled
- Backup retention period: 7 days
- Test recovery procedures regularly
- Document recovery time objectives (RTO)

### Scaling
- Monitor resource utilization
- Plan for vertical and horizontal scaling
- Document scaling procedures

## Maintenance

### Regular Tasks
1. Review and apply AWS patches
2. Monitor and optimize costs
3. Review security groups and access policies
4. Update SSL certificates
5. Review and update backup strategies

### Emergency Procedures
Document steps for:
1. Database failover
2. Security incident response
3. Service restoration
4. Data recovery

## Support and Escalation

1. First Level: Infrastructure Team
2. Second Level: AWS Support (if applicable)
3. Emergency Contact: [Your emergency contact]

## Compliance and Auditing

- Regular security audits
- Compliance checks
- Access reviews
- Change management procedures

## Version Control

- Tag all production releases
- Document all changes
- Maintain changelog
- Review pull requests

For any issues or questions, please follow the escalation procedure outlined in our support documentation.

# HustleMode.AI Website

This repository contains the landing page for HustleMode.AI, an AI accountability coach available through iMessage.

## Setup Instructions

### 1. GitHub Repository Setup
```bash
# Clone the repository
git clone git@github.com:vbkotecha/hustlemode.ai.git
cd hustlemode.ai

# Initialize Git repository
git init
git add .
git commit -m "Initial commit"
git branch -M main

# Add remote repository
git remote add origin git@github.com:vbkotecha/hustlemode.ai.git
git push -u origin main
```

### 2. GitHub Pages Configuration
1. Go to your repository on GitHub
2. Navigate to Settings > Pages
3. Under "Source", select "Deploy from a branch"
4. Select "main" branch and "/" (root) folder
5. Click Save
6. Enable "Enforce HTTPS"

### 3. Namecheap DNS Configuration
1. Log in to your Namecheap account
2. Go to Domain List > Manage
3. Click on "Advanced DNS"
4. Add the following A records:
   ```
   A Record @ 185.199.108.153
   A Record @ 185.199.109.153
   A Record @ 185.199.110.153
   A Record @ 185.199.111.153
   ```
5. Add CNAME record:
   ```
   CNAME Record www -> vbkotecha.github.io
   ```
6. Wait for DNS propagation (can take up to 24 hours)

### 4. Verify Setup
1. Visit https://hustlemode.ai to verify the main domain works
2. Visit https://www.hustlemode.ai to verify the www subdomain works
3. Check that HTTPS is working correctly
4. Verify that all assets (images, styles) load properly

## File Structure
```
/
├── index.html          # Main landing page
├── 404.html           # Custom 404 error page
├── styles.css         # Stylesheet
├── CNAME             # Custom domain configuration
├── robots.txt        # Search engine configuration
├── sitemap.xml       # Site structure for search engines
├── site.webmanifest  # Progressive Web App configuration
└── assets/
    └── images/       # Image assets
```

## Development

### Local Testing
```bash
# Using Python's built-in server
python -m http.server 8000

# Or using Node's http-server
npx http-server
```

### Performance Testing
1. Use [Google PageSpeed Insights](https://pagespeed.web.dev/)
2. Check [Google Search Console](https://search.google.com/search-console)
3. Validate [Schema Markup](https://validator.schema.org/)

## Maintenance

### Updating Content
1. Edit the relevant HTML/CSS files
2. Test locally
3. Commit and push changes:
   ```bash
   git add .
   git commit -m "Update description"
   git push
   ```

### SSL/HTTPS
- SSL is automatically managed by GitHub Pages
- Ensure HTTPS enforcement is enabled in GitHub Pages settings

## Support
For any issues or questions, please contact:
- [Vivek Kotecha](https://www.linkedin.com/in/vbkotecha/)

# HustleMode.AI Infrastructure

This repository contains the infrastructure and backend code for HustleMode.AI, an AI-powered personal assistant.

## Project Structure

```
.
├── infrastructure/    # Terraform configurations for AWS resources
├── lambda/           # AWS Lambda function code
└── backend/          # Python FastAPI backend service
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- Python >= 3.11
- Node.js >= 18 (for Lambda functions)

## Setup

1. Clone the repository:
   ```bash
   git clone git@github.com:vbkotecha/hustlemode-infra.git
   cd hustlemode-infra
   ```

2. Create `terraform.tfvars` from the example:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` with your configuration values.

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Deploy the infrastructure:
   ```bash
   terraform plan    # Review the changes
   terraform apply   # Apply the changes
   ```

## Backend Development

1. Set up a Python virtual environment:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. Run the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

## Lambda Functions

1. Install dependencies:
   ```bash
   cd lambda
   npm install
   ```

2. Deploy Lambda functions:
   ```bash
   terraform apply -target=module.lambda
   ```

## Environment Variables

Create a `.env` file in the backend directory with the following variables:
```
AWS_REGION=us-east-1
DYNAMODB_TABLE=hustlemode-tasks
OPENAI_API_KEY=your_api_key
```

## Security

- Never commit sensitive information like API keys or credentials
- Use AWS KMS for encrypting sensitive values
- Follow the principle of least privilege for IAM roles

## Contributing

1. Create a new branch for your feature
2. Make your changes
3. Submit a pull request

## License

Copyright © 2024 Vivek Kotecha. All rights reserved. 