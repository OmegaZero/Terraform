output "server_mac_address" {
  value = "${libvirt_domain.server.*.network_interface.0.mac}"
}

output "server_ip_addresses" {
   value = "${libvirt_domain.server.*.network_interface.0.addresses}"
 }
