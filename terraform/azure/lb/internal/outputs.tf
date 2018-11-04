output "lb_private_ip" {
  value = ["${azurerm_lb.internal.*.private_ip_address}"]
}

output "lb_id" {
  value = ["${azurerm_lb.internal.*.id}"]
}

output "lb_pool_id" {
  value = "${azurerm_lb_backend_address_pool.this.id}"
}