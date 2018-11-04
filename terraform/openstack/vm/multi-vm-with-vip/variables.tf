variable "site_name" { default = "demo" }

variable "vnet" {}
variable "subnet" {}
variable "sg_ids" {
  type = "list"
}

variable "name" {}
variable "os" {}
variable "ssh_public_key" { default = "keypair" }
variable "user_data" {
  default = ""
}

variable "count" { default = 1 }
variable "size" { default = "m4.large" }
variable "ext_vol_size" {
  default = 0
}

variable "ext_vol_type" {
  default = ""
  description = "This should be a valid value of cinder availability zone."
}

variable "virtual_ip" { }