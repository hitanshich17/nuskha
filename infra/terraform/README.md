# Terraform (coming later)

This folder will define the AWS deployment:

- One EC2 instance (t4g.small) running the services with Docker Compose
- S3 bucket for label images, SQS queue + dead-letter queue for scan jobs
- IAM roles with least-privilege access, CloudWatch logs and alarms
- An AWS Budget with email alerts
- GitHub Actions OIDC role so CI can deploy without stored AWS keys

Nothing here is needed for local development.
