resource "aws_iam_role" "lambda_role" {
  name                = "ansible-lambda-role"
  path                = "/service-role/"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_policy" "lambda_policy" {
  name    = "ansible-lambda-policy"
  policy  = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_policy_attachment" "lambda_role_policy_attachment" {
  name        = "ansible-lambda-policy-attachment"
  policy_arn  = aws_iam_policy.lambda_policy.arn
  roles       = [
    aws_iam_role.lambda_role.name
  ]
}

resource "aws_lambda_function" "lambda_function" {
  depends_on = [
    aws_iam_role.lambda_role
  ]
  function_name     = "ansible-provisioning"
  handler           = "lambda_function.lambda_handler"
  role              = aws_iam_role.lambda_role.arn
  runtime           = "python3.8"
  filename          = data.archive_file.lambda_zip.output_path
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
  publish           = true
  timeout           = 15
  memory_size       = 128
  environment {
    variables = {
      code_bucket = "acg-demo-ansible"
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_event_invoke_config" {
  depends_on = [
    aws_lambda_function.lambda_function
  ]
  function_name           = aws_lambda_function.lambda_function.function_name
  qualifier               = "$LATEST"
  maximum_retry_attempts  = 0
}

resource "aws_sns_topic" "sns_topic" {
  name          = "ansible-sns-topic"
  display_name  = "Ansible SNS Topic"
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  depends_on = [
    aws_lambda_function.lambda_function,
    aws_sns_topic.sns_topic
  ]
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_function.arn
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  depends_on = [
    aws_sns_topic.sns_topic
  ]
  arn     = aws_sns_topic.sns_topic.arn
  policy  = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_cloudwatch_event_rule" "cloudwatch_event" {
  name          = "ansible-instance-state"
  description   = "Capture when instance stage changes to apply Ansible code"
  event_pattern = <<EOF
{
    "source": [
        "aws.ec2"
    ],
    "detail-type": [
        "EC2 Instance State-change Notification"
    ],
    "detail": {
        "state": [
            "running",
            "stopped",
            "terminated"
        ]
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "sns_target" {
  depends_on = [
    aws_lambda_function.lambda_function,
    aws_cloudwatch_event_rule.cloudwatch_event
  ]
  rule      = aws_cloudwatch_event_rule.cloudwatch_event.name
  target_id = "TriggerTarget"
  arn       = aws_sns_topic.sns_topic.arn
}

resource "aws_lambda_permission" "sns_permission" {
  depends_on = [
    aws_lambda_function.lambda_function,
    aws_sns_topic.sns_topic
  ]
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns_topic.arn
}