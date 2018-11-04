variable "site_name" { default = "demo" }
variable "resource_group_name" {}

variable "vnet" {}
variable "subnet" {}
variable "storage_account" {}

variable "name" {}
variable "os" {
  type = "list"
  default = ["OpenLogic", "CentOS", "7.5", "latest", ""]
}

variable "os_user" {
  default = "cloud-user"
}

variable "count" { default = 1 }
variable "size" { default = "Standard_B2s" }

variable "ssh_public_key" { default = "" }