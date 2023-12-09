resource "aws_iam_role" "_" {
  name = local.iam_name
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "states.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "_" {
  name = local.iam_name
  role = aws_iam_role._.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ext" {
  count = var.policy_statements == [] ? 0 : 1
  role  = aws_iam_role._.id
  name  = "${local.iam_name}_ext"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : var.policy_statements
  })
}

resource "aws_sfn_state_machine" "_" {
  name     = local.name
  role_arn = aws_iam_role._.arn
  publish  = var.publish

  definition = jsonencode(
    var.state_machine
  )
}
