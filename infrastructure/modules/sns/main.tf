resource "aws_sns_topic" "_" {
  name = local.name
}

resource "aws_sns_topic_subscription" "_" {
  for_each  = var.subscriptions
  topic_arn = aws_sns_topic._.arn
  protocol  = each.key
  endpoint  = each.value
}

resource "aws_lambda_permission" "_" {
  count         = var.lambda == null ? 0 : 1
  action        = "lambda:InvokeFunction"
  function_name = var.lambda.function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic._.arn
}
