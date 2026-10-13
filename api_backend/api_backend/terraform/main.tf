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
      DATABASE_URL        = var.database_url
      DATABASE_USERNAME   = var.database_username
      DATABASE_PASSWORD   = var.database_password
      JWT_SECRET          = var.jwt_secret
      FILE_STORAGE_BUCKET = aws_s3_bucket.file_storage.id
      SNS_TOPIC_ARN       = aws_sns_topic.notifications.arn
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

# ---------- SNS ----------
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-notifications"
}

# ---------- SQS + DLQ ----------
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-notifications-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "notifications" {
  name                       = "${var.project_name}-notifications-queue"
  visibility_timeout_seconds = 180 # debe ser >= timeout de la lambda (idealmente 6x)
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "allow_sns" {
  queue_url = aws_sqs_queue.notifications.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.notifications.arn
      Condition = { ArnEquals = { "aws:SourceArn" = aws_sns_topic.notifications.arn } }
    }]
  })
}

# ---------- Suscripción SNS -> SQS ----------
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn            = aws_sns_topic.notifications.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.notifications.arn
  raw_message_delivery = true
}

# ---------- SES (el remitente recibirá un correo de verificación) ----------
resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

# ---------- IAM de notification-lambda ----------
resource "aws_iam_role" "notification_lambda" {
  name = "${var.project_name}-notification-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "notification_logs" {
  role       = aws_iam_role.notification_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "notification_permissions" {
  name = "sqs-and-ses"
  role = aws_iam_role.notification_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.notifications.arn
      },
      {
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "*"
      }
    ]
  })
}

# ---------- CloudWatch Logs ----------
resource "aws_cloudwatch_log_group" "notification" {
  name              = "/aws/lambda/notification-lambda"
  retention_in_days = 7
}

# ---------- Lambda ----------
data "archive_file" "notification_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../notification-lambda"
  output_path = "${path.module}/notification-lambda.zip"
}

resource "aws_lambda_function" "notification" {
  function_name    = "notification-lambda"
  role             = aws_iam_role.notification_lambda.arn
  runtime          = "python3.12"
  handler          = "lambda_function.handler"
  filename         = data.archive_file.notification_zip.output_path
  source_code_hash = data.archive_file.notification_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = { SENDER_EMAIL = var.sender_email }
  }

  depends_on = [aws_cloudwatch_log_group.notification]
}

# ---------- Event Source Mapping SQS -> Lambda ----------
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn        = aws_sqs_queue.notifications.arn
  function_name           = aws_lambda_function.notification.arn
  batch_size              = 5
  function_response_types = ["ReportBatchItemFailures"]
}

# ---------- Permiso para que la Lambda principal publique en SNS ----------
# Adapta "aws_iam_role.backend_lambda" al nombre real del rol de tu Lambda principal
resource "aws_iam_role_policy" "backend_publish_sns" {
  name = "publish-sns"
  role = aws_iam_role.lambda_role.id   # <-- antes: backend_lambda
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.notifications.arn
    }]
  })
}