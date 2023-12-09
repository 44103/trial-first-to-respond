variable "commons" {}
variable "name" {}
variable "publish" {}
variable "state_machine" {}
variable "policy_statements" {}

locals {
  name = join("_", [
    var.commons.workspace,
    var.name,
    var.commons.service,
    var.commons.project
  ])
  iam_name = join("_", ["sfn", local.name])
}
