variable "commons" {}
variable "name" {
  description = "resource name"
}
variable "envs" {
  description = "environments"
  default     = {}
}
variable "policy_statements" {
  default = []
}

locals {
  name = join("_", [
    var.commons.workspace,
    var.name,
    var.commons.service,
    var.commons.project
  ])
  iam_name = join("_", ["lambda", local.name])
  envs = merge(
    { "TZ" = "Asia/Tokyo" },
    var.envs
  )
  func_dir = "${path.module}/../../functions/lambda"
}
