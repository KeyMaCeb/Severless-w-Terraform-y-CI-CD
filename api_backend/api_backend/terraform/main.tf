resource "aws_iam_role" "lambda_role" {
  name = "api-backend-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "api" {
  function_name = "api-backend"
  role          = aws_iam_role.lambda_role.arn

  s3_bucket        = aws_s3_bucket.lambda_artifact.id
  s3_key           = aws_s3_object.lambda_jar.key
  source_code_hash = filebase64sha256("../target/api_backend-0.0.1-SNAPSHOT-shaded.jar")

  handler = "com.keysi.api_backend.handler.StreamLambdaHandler::handleRequest"
  runtime = "java17"

  timeout     = 30
  memory_size = 1024

  environment {
    variables = {
      DATABASE_URL      = var.database_url
      DATABASE_USERNAME = var.database_username
      DATABASE_PASSWORD = var.database_password
      JWT_SECRET        = var.jwt_secret
      FILE_STORAGE_BUCKET = aws_s3_bucket.file_storage.id
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "api-backend-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_s3_bucket" "lambda_artifact" {
  bucket_prefix = "api-backend-lambda-"

  force_destroy = true
}

resource "aws_s3_object" "lambda_jar" {
  bucket = aws_s3_bucket.lambda_artifact.id
  key    = "api-backend.jar"
  source = "../target/api_backend-0.0.1-SNAPSHOT-shaded.jar"

  etag = filemd5("../target/api_backend-0.0.1-SNAPSHOT-shaded.jar")
}

resource "aws_s3_bucket" "file_storage" {
  bucket_prefix = "api-backend-files-"

  force_destroy = true
}

resource "aws_iam_role_policy" "lambda_s3_files" {
  name = "api-backend-lambda-s3-files"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.file_storage.arn}/*"
      }
    ]
  })
}