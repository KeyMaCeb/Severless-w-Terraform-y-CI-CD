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

output "sns_topic_arn"      { value = aws_sns_topic.notifications.arn }
output "sqs_queue_url"      { value = aws_sqs_queue.notifications.id }
output "notification_lambda" { value = aws_lambda_function.notification.function_name }