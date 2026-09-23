#!/bin/bash
# Runs automatically when LocalStack is ready. Creates the same resources Terraform will create on AWS.
set -euo pipefail

awslocal s3 mb s3://skinvidhi-label-images

# Dead-letter queue: jobs that fail repeatedly land here instead of retrying forever.
awslocal sqs create-queue --queue-name label-scan-jobs-dlq
DLQ_ARN=$(awslocal sqs get-queue-attributes \
  --queue-url http://localhost:4566/000000000000/label-scan-jobs-dlq \
  --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

awslocal sqs create-queue --queue-name label-scan-jobs \
  --attributes "{\"RedrivePolicy\":\"{\\\"deadLetterTargetArn\\\":\\\"${DLQ_ARN}\\\",\\\"maxReceiveCount\\\":\\\"3\\\"}\"}"

echo "LocalStack resources created: s3://skinvidhi-label-images, label-scan-jobs (+ DLQ)"
