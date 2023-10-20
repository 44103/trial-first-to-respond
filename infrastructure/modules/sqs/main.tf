resource "aws_sqs_queue" "_" {
  name = local.name
}

resource "aws_sns_topic_subscription" "_" {
  topic_arn = var.sns.topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue._.arn
}

resource "aws_sqs_queue_policy" "_" {
  queue_url = aws_sqs_queue._.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : { "AWS" : "*" },
          "Action" : "SQS:SendMessage",
          "Resource" : aws_sqs_queue._.arn,
          "Condition" : {
            "ArnLike" : {
              "aws:SourceArn" : var.sns.topic.arn
            }
          }
        }
      ]
    }
  )
}
