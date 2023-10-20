data "aws_caller_identity" "_" {}

module "sns" {
  source  = "../modules/sns"
  commons = local.commons
  name    = "delivery_request"
}

module "sqs" {
  source = "../modules/sqs"
  commons = local.commons
  name = "notification"
  sns = module.sns
}
