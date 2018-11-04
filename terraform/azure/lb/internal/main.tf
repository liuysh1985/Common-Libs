// Create an loadbalancer for web service
data "azurerm_resource_group" "lab" {
  name = "${var.resource_group_name}"
}

data "azurerm_subnet" "internal" {
  name                 = "${var.subnet}"
  virtual_network_name = "${var.vnet}"
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_lb" "internal" {
  name                = "${var.site_name}-${var.name}-internal"
  location            = "${data.azurerm_resource_group.lab.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "ft_ip_cfg"
    subnet_id                     = "${data.azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_rule" "this" {
  count                          = "${length(var.ports)}"
  name                           = "rule-${element(var.ports, count.index)}"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.internal.id}"
  protocol                       = "Tcp"
  frontend_port                  = "${element(var.ports, count.index)}"
  backend_port                   = "${element(var.ports, count.index)}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.this.id}"
  frontend_ip_configuration_name = "ft_ip_cfg"
  probe_id                       = "${element(azurerm_lb_probe.this.*.id, count.index)}"
}

resource "azurerm_lb_probe" "this" {
  count               = "${length(var.ports)}"
  name                = "probe-${element(var.ports, count.index)}"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.internal.id}"
  protocol            = "Tcp"
  port                = "${element(var.ports, count.index)}"
}
# This pool will contain all web instance's nics.
resource "azurerm_lb_backend_address_pool" "this" {
  name                = "default_address_pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.internal.id}"
}