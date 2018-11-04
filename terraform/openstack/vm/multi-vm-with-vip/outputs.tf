output "vm_hostname" {
  value = ["${openstack_compute_instance_v2.vm.*.name}"]
}

output "vm_private_ip" {
  value = ["${openstack_compute_instance_v2.vm.*.access_ip_v4}"]
}