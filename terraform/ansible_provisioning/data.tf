data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/"
  output_path = "${path.module}/files/lambda.zip"
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    actions   = [
      "ssm:*",
      "ec2:DescribeInstances",
      "ec2:CreateTags"
    ]
    effect    = "Allow"
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid       = "CloudwatchEventPublish"
    actions   = [
      "sns:Publish"
    ]
    effect    = "Allow"
    resources = [
      aws_sns_topic.sns_topic.arn
    ]
    principals {
      identifiers = [
        "events.amazonaws.com"
      ]
      type        = "Service"
    }
  }

  statement {
    sid       = "__default_statement_ID"
    actions   = [
      "sns:Subscribe",
      "sns:SetTopicAttributes",
      "sns:RemovePermission",
      "sns:Receive",
      "sns:Publish",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:DeleteTopic",
      "sns:AddPermission"
    ]
    effect    = "Allow"
    resources = [
      aws_sns_topic.sns_topic.arn
    ]
    condition {
      test      = "StringEquals"
      values    = [
        data.aws_caller_identity.current.account_id
      ]
      variable  = "AWS:SourceOwner"
    }
    principals {
      identifiers = [
        "*"
      ]
      type        = "AWS"
    }
  }
}
