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
variable "ext_vol_size" {
  default = 100
}
variable "ext_vol_type" {
  default = "Standard_LRS"
}

variable "ssh_public_key" { default = "" }