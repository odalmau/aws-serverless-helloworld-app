output "api_gateway_url" {
  description = "API base URL"
  value       = "${aws_api_gateway_stage.hello_world.invoke_url}/hello"
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.hello_world.function_name
}
