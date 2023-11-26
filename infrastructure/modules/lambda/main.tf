resource "aws_iam_role" "_" {
  name = local.iam_name
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "lambda.amazonaws.com"
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
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "${aws_cloudwatch_log_group._.arn}:*"
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

data "archive_file" "_" {
  type        = "zip"
  source_dir  = "${local.func_dir}/${var.name}/"
  output_path = "${local.func_dir}/dist/${var.name}/source.zip"
}

resource "aws_lambda_function" "_" {
  function_name    = local.name
  role             = aws_iam_role._.arn
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  filename         = data.archive_file._.output_path
  source_code_hash = data.archive_file._.output_base64sha256

  environment {
    variables = local.envs
  }
}

resource "aws_cloudwatch_log_group" "_" {
  name = "/aws/lambda/${local.name}"
}
