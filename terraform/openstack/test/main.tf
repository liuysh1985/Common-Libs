provider "openstack" {
  version = "~> 1.11"
}


module "single" {
  source = "../vm/single-vm"

  vnet = "test-vnet"
  subnet = "test-subnet"
  sg_ids = ["xxx"]
  name = "test-vm"
  os = "xxx"
}

module "multi" {
  source = "../vm/multi-vm"

  vnet = "test-vnet"
  subnet = "test-subnet"
  sg_ids = ["xxx"]
  name = "test-multi-vm"
  count = 2
  os = "xxx"
  ext_vol_size = 200
}

module "cep" {
  source = "../vm/multi-vm-with-vip"

  vnet = "test-vnet"
  subnet = "test-subnet"
  sg_ids = ["xxx"]
  name = "test-cep-vm"
  count = 2
  os = "xxx"
  ext_vol_size = 200
  virtual_ip = "xx.xx.xx.xx"
}