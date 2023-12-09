variable "commons" {}
variable "name" {
  description = "resource name"
}
variable "policy_statements" {}

locals {
  name = join("_", [
    var.commons.workspace,
    var.name,
    var.commons.service,
    var.commons.project
  ])
}
