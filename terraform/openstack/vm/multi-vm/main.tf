data "openstack_images_image_v2" "os" {
  name        = "${var.os}"
  most_recent = true
}

data "openstack_networking_network_v2" "traffic" {
  name = "${var.vnet}"
}

data "openstack_networking_subnet_v2" "traffic" {
  name = "${var.subnet}"
}

resource "openstack_networking_port_v2" "traffic" {
  count              = "${var.count}"
  name               = "${var.site_name}-${var.name}-${count.index + 1}-traffic-port"
  network_id         = "${data.openstack_networking_network_v2.traffic.id}"
  admin_state_up     = "true"
  security_group_ids = ["${var.sg_ids}"]

  fixed_ip {
    subnet_id = "${data.openstack_networking_subnet_v2.traffic.id}"
  }

  value_specs {
    dns_name = "${var.name}-${count.index + 1}"
  }
}

resource "openstack_compute_instance_v2" "vm" {
  count               = "${var.count}"
  name                = "${var.name}-${count.index + 1}"
  flavor_name         = "${var.size}"
  key_pair            = "${var.ssh_public_key}"
  user_data           = "${var.user_data}"
  stop_before_destroy = true

  block_device {
    uuid                  = "${data.openstack_images_image_v2.os.id}"
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = "${openstack_networking_port_v2.traffic.*.id[count.index]}"
  }
}

resource "openstack_blockstorage_volume_v2" "ext_vols" {
  count             = "${var.ext_vol_size>0?var.count:0}"
  name              = "${replace(var.name,"-","_")}_${count.index + 1}_ext_vol"
  size              = "${var.ext_vol_size}"
  availability_zone = "${var.ext_vol_type}"

  timeouts {
    create = "10m"
    delete = "30m"
  }
}

resource "openstack_compute_volume_attach_v2" "ext_vol_attach" {
  count       = "${var.ext_vol_size>0?var.count:0}"
  instance_id = "${element(openstack_compute_instance_v2.vm.*.id, count.index)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.ext_vols.*.id, count.index)}"
}
