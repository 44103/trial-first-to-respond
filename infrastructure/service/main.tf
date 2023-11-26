data "aws_caller_identity" "_" {}

module "sns" {
  source  = "../modules/sns"
  commons = local.commons
  name    = "delivery_request"
}

module "sqs" {
  source  = "../modules/sqs"
  commons = local.commons
  name    = "notification"
  sns     = module.sns
}

module "lambda" {
  source  = "../modules/lambda"
  commons = local.commons
  name    = "driver_sally"
  policy_statements = [
    {
      "Effect" : "Allow",
      "Action" : [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
      ],
      "Resource" : "*"
    }
  ]
}
