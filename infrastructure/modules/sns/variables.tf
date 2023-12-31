variable "commons" {}
variable "name" {
  description = "resource name"
}
variable "lambda" {
  default = null
}
variable "subscriptions" {}

locals {
  name = join("_", [
    var.commons.workspace,
    var.name,
    var.commons.service,
    var.commons.project
  ])
}
