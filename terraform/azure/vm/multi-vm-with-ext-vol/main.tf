data "azurerm_resource_group" "lab" {
  name = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "vnet" {
  name                 = "${var.vnet}"
  resource_group_name  = "${var.resource_group_name}"
}

data "azurerm_subnet" "traffic" {
  name                 = "${var.subnet}"
  virtual_network_name = "${var.vnet}"
  resource_group_name  = "${var.resource_group_name}"
}

data "azurerm_storage_account" "lab" {
  name                 = "${var.storage_account}"
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_availability_set" "vm" {
  count               = "${var.count>0?1:0}"
  name                = "${var.site_name}_${var.name}_aset"
  location            = "${data.azurerm_resource_group.lab.location}"
  resource_group_name = "${var.resource_group_name}"
  managed             = true
}

resource "azurerm_network_interface" "traffic" {
  count                     = "${var.count}"
  name                      = "${var.site_name}_${var.name}_traffic_nic_${count.index + 1}"
  location                  = "${data.azurerm_resource_group.lab.location}"
  resource_group_name       = "${var.resource_group_name}"

  internal_dns_name_label   = "${replace(var.name,"_","-")}-${count.index + 1}"

  ip_configuration {
    name                                    = "primary_ip_cfg"
    subnet_id                               = "${data.azurerm_subnet.traffic.id}"
    private_ip_address_allocation           = "dynamic"
    # load_balancer_backend_address_pools_ids = ["${var.lb_pool_ids}"]
  }
}

resource "azurerm_managed_disk" "vm_ext_vols" {
  count                = "${var.count}"
  name                 = "${var.site_name}_${var.name}_${count.index + 1}_Ext_Disk"
  location             = "${data.azurerm_resource_group.lab.location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "${var.ext_vol_type}"
  create_option        = "Empty"
  disk_size_gb         = "${var.ext_vol_size}"
}

resource "azurerm_virtual_machine" "instance" {
  count                            = "${var.count}"
  name                             = "${var.site_name}-${replace(var.name,"_","-")}-${count.index + 1}"
  location                         = "${data.azurerm_resource_group.lab.location}"
  resource_group_name              = "${var.resource_group_name}"
  network_interface_ids            = ["${element(azurerm_network_interface.traffic.*.id, count.index)}"]
  vm_size                          = "${var.size}"
  availability_set_id              = "${azurerm_availability_set.vm.id}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.os[0]}"
    offer     = "${var.os[1]}"
    sku       = "${var.os[2]}"
    version   = "${var.os[3]}"
    id        = "${var.os[4]}"
  }

  storage_os_disk {
    name              = "${var.site_name}_${var.name}_${count.index + 1}_OS_Disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name             = "${var.site_name}_${var.name}_${count.index + 1}_Ext_Disk"
    lun              = "0"
    create_option    = "Attach"
    disk_size_gb     = "${var.ext_vol_size}"
    managed_disk_id  = "${element(azurerm_managed_disk.vm_ext_vols.*.id, count.index)}"
  }

  os_profile {
    computer_name     = "${replace(var.name,"_","-")}-${count.index + 1}"
    admin_username    = "${var.os_user}"
  }
  
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.os_user}/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${data.azurerm_storage_account.lab.primary_blob_endpoint}"
  }
}