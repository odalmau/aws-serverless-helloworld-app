# aws-serverless-helloworld-app

Deploy a simple "Hello World" HTTP application with AWS Lambda and API Gateway using Terraform.

### Prerequisites

The Terraform code assumes the S3 bucket used for the backend is already created. The following configuration is used:

```
terraform {
  backend "s3" {
    bucket = "terraform-backend-aws-serverless-helloworld"
    key    = "development"
    region = "us-east-1"
  }
}
```

### CI/CD

The GitHub Actions worflow has been configured to perform the following actions:

1. Lint Lambda Python code.
2. On pull request events, run `terraform init`, `terraform fmt`, and `terraform plan`.
3. On push events to the "main" branch, run `terraform apply` and ensure the application is working as expected.