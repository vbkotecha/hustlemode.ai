#!/bin/bash

# deploy.sh
#
# This script deploys the website to AWS S3 and invalidates the CloudFront cache.
#
# Author: Vivek Kotecha
# Last Updated: 2024

# Exit on error
set -e

# Get the S3 bucket name and CloudFront distribution ID from Terraform outputs
S3_BUCKET=$(cd ../infrastructure && terraform output -raw s3_bucket_name)
CLOUDFRONT_DIST_ID=$(cd ../infrastructure && terraform output -raw cloudfront_distribution_id)

echo "Deploying website to S3 bucket: $S3_BUCKET"

# Sync website files to S3
aws s3 sync . s3://$S3_BUCKET \
    --exclude "deploy.sh" \
    --exclude ".DS_Store" \
    --exclude "*/.DS_Store" \
    --delete \
    --cache-control "max-age=3600"

echo "Website files uploaded to S3"

# Invalidate CloudFront cache
echo "Invalidating CloudFront cache for distribution: $CLOUDFRONT_DIST_ID"
aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DIST_ID \
    --paths "/*"

echo "Deployment complete! The website should be live in a few minutes."
echo "Visit: https://www.hustlemode.ai" 