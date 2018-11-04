provider "azurerm" {
  version = "~> 1.18"
}


module "internal-lb" {
  source = "../lb/internal"
  
  resource_group_name = "test-res-group"
  vnet = "test-vnet"
  subnet = "test-subnet"
  # public = true
  name = "test"
  ports = ["443", "8883"]
}

module "test-vm-1" {
  source = "../vm/multi-vm"
  
  resource_group_name = "test-res-group"
  vnet = "test-vnet"
  subnet = "test-subnet"
  storage_account = "xxx"
  name = "test-vm-1"
  count = 2
  ssh_public_key = "ssh-rsa xxxxx"
}

module "test-vm-2" {
  source = "../vm/multi-vm-with-ext-vol"
  
  resource_group_name = "test-res-group"
  vnet = "test-vnet"
  subnet = "test-subnet"
  storage_account = "xxx"
  name = "test-vm-1"
  count = 3
  ext_vol_size = "200"
  ssh_public_key = "ssh-rsa xxxxx"
}

