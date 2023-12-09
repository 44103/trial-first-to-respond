resource "aws_sqs_queue" "_" {
  name = local.name
}

resource "aws_sqs_queue_policy" "_" {
  queue_url = aws_sqs_queue._.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : var.policy_statements
    }
  )
}
