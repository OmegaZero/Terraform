resource "libvirt_domain" "server" {

  # domain name in libvirt, not hostname
  name = "${var.server_name}"
  memory = "8192"
  vcpu = 2

  qemu_agent = true

  ######################### UEFI ###########################################
  #UEFI Firmware (replaces BIOS)
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"

  #UEFI RAM
  nvram {
    file = "/var/lib/libvirt/qemu/nvram/${var.server_name}_VARS.fd"
    template = "/usr/share/OVMF/OVMF_VARS.fd"
  }
  ##########################################################################

  video {
    type = "qxl"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  autostart = true

  network_interface {
    bridge ="br0"
    hostname = "${var.server_name}"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.base-image.id
  }

  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  xml {
    xslt = file("./scripts/add_spicevmc.xsl")
  }

  connection {
    type     = "winrm"
    user     = "Vagrant"
    password = "vagrant"
    host     = "${self.network_interface.0.addresses.1}"
  }

}
