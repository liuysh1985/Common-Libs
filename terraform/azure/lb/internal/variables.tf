variable "site_name" { default = "demo" }
variable "resource_group_name" {}

variable "vnet" { }

variable "subnet" {}

variable "name" {}
variable "ports" {
  type = "list"
  default = []
}