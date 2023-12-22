variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-west-2"
}

variable "lambda_function_name" {
  description = "AWS lambda function name."

  type    = string
  default = "HelloWorld"
}

variable "lambda_python_version" {
  description = "AWS lambda runtime Python version."

  type    = string
  default = "3.12"
}
