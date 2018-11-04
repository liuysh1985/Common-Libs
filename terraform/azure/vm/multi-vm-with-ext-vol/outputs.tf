output "vm_internal_fqdn" {
  value = ["${azurerm_network_interface.traffic.*.internal_fqdn}"]
}

output "vm_private_ip" {
  value = ["${azurerm_network_interface.traffic.*.private_ip_address}"]
}

output "vm_nic_id" {
  value = ["${azurerm_network_interface.traffic.*.id}"]
}