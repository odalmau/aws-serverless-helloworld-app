# Create Lambda function ZIP file
data "archive_file" "hello_world" {
  type = "zip"

  source_dir  = "${path.module}/hello_world_lambda"
  output_path = "${path.module}/hello_world_lambda.zip"
}

# Create Lambda function
resource "aws_lambda_function" "hello_world" {
  function_name    = var.lambda_function_name
  filename         = "${path.module}/hello_world_lambda.zip"
  handler          = "hello_world_lambda.hello_world_handler"
  runtime          = "python${var.lambda_python_version}"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.hello_world.output_base64sha256
}

# Create Lambda IAM role
data "aws_iam_policy_document" "lambda_exec" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

# Create and configure API Gateway
resource "aws_api_gateway_rest_api" "hello_world" {
  name        = "HelloWorldAPI"
  description = "API for Hello World Lambda function"
}

resource "aws_api_gateway_resource" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id
  parent_id   = aws_api_gateway_rest_api.hello_world.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_world" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  resource_id   = aws_api_gateway_resource.hello_world.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id             = aws_api_gateway_rest_api.hello_world.id
  resource_id             = aws_api_gateway_resource.hello_world.id
  http_method             = aws_api_gateway_method.hello_world.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_world.invoke_arn
}

# Allow API Gateway to invoke Lambda function
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_world.execution_arn}/*/*"
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.hello_world.id

  depends_on = [
    aws_api_gateway_integration.hello_world_integration
  ]
}

resource "aws_api_gateway_stage" "hello_world" {
  deployment_id = aws_api_gateway_deployment.hello_world.id
  rest_api_id   = aws_api_gateway_rest_api.hello_world.id
  stage_name    = "development"
}