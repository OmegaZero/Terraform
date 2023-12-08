output "DC_mac_address" {
  value = "${libvirt_domain.dc.*.network_interface.0.mac}"
}

output "DC_ip_addresses" {
   value = "${libvirt_domain.dc.*.network_interface.0.addresses}"
 }


output "SQL_1_ip_addresses" {
   value = "${libvirt_domain.SQL_1.*.network_interface.0.addresses}"
 }
