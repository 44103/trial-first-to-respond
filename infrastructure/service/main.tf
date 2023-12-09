data "aws_caller_identity" "_" {}

module "sns" {
  source  = "../modules/sns"
  commons = local.commons
  name    = "delivery_request"
  subscriptions = {
    sqs    = module.sqs.queue.arn
    lambda = module.lambda.function.arn
  }
  lambda = module.lambda
}

module "sqs" {
  source  = "../modules/sqs"
  commons = local.commons
  name    = "notification"
  policy_statements = [
    {
      "Effect" : "Allow",
      "Principal" : { "AWS" : "*" },
      "Action" : "SQS:SendMessage",
      "Resource" : module.sqs.queue.arn,
      "Condition" : {
        "ArnLike" : {
          "aws:SourceArn" : module.sns.topic.arn
        }
      }
    }
  ]
}

module "lambda" {
  source  = "../modules/lambda"
  commons = local.commons
  name    = "driver_sally"
  policy_statements = [
    {
      "Effect" : "Allow",
      "Action" : "states:*",
      "Resource" : "*"
    }
  ]
}

module "sfn" {
  source  = "../modules/sfn"
  commons = local.commons
  name    = "process_new_delivery"
  publish = true
  policy_statements = [
    {
      "Effect" : "Allow",
      "Action" : [
        "sns:Publish"
      ],
      "Resource" : [
        module.sns.topic.arn
      ]
    }
  ]
  state_machine = {
    "StartAt" : "Check Inventory",
    "States" : {
      "Check Inventory" : {
        "Type" : "Pass",
        "OutputPath" : "$",
        "Next" : "Place CC Hold"
      },
      "Place CC Hold" : {
        "Type" : "Pass",
        "OutputPath" : "$",
        "Next" : "Request Driver"
      },
      "Request Driver" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::sns:publish.waitForTaskToken",
        "TimeoutSeconds" : 15,
        "Parameters" : {
          "Message" : {
            "TaskToken.$" : "$$.Task.Token",
            "Input.$" : "$.OrderNumber"
          },
          "TopicArn" : module.sns.topic.arn
        },
        "Catch" : [{
          "ErrorEquals" : ["States.Timeout"],
          "Next" : "Notify Customer of Delay"
        }],
        "Next" : "Delivery Assigned to Driver"
      },
      "Delivery Assigned to Driver" : {
        "Type" : "Pass",
        "OutputPath" : "$",
        "End" : true
      },
      "Notify Customer of Delay" : {
        "Type" : "Pass",
        "OutputPath" : "$",
        "End" : true
      }
    }
  }
}
