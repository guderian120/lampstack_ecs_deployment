resource "aws_sns_topic" "failover_alert" {
  name = "failover-alert-topic"
}

# Allow cross-region Lambda to subscribe
resource "aws_sns_topic_policy" "failover_policy" {
  arn    = aws_sns_topic.failover_alert.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.failover_alert.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]  # Restrict to specific accounts in production
    }
  }
}