# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.1/website/docs/r/network.markdown
# resource "libvirt_network" "mytest_network" {
#   name      = var.prefix
#   mode      = "nat"
#   domain    = "example.test"
#   addresses = ["192.168.75.0/24"]
#   dhcp {
#     enabled = false
#   }
#   dns {
#     enabled    = true
#     local_only = false
#   }
#   lifecycle {
#     ignore_changes = [
#       dhcp[0].enabled, # see https://github.com/dmacvicar/terraform-provider-libvirt/issues/998
#     ]
#   }
# }

