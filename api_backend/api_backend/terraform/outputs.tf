output "api_gateway_url" {
  description = "URL publica del API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_function_name" {
  description = "Nombre de la funcion Lambda"
  value       = aws_lambda_function.api.function_name
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 donde se almacena el JAR"
  value       = aws_s3_bucket.lambda_artifact.id
}