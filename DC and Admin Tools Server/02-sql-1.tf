# volume to attach to the domain as main disk
resource "libvirt_volume" "SQL_1_root" {
  name           = "${var.SQL_1_name}-root.qcow2"
  base_volume_id = libvirt_volume.base-image.id
}

resource "libvirt_domain" "SQL_1" {

  # domain name in libvirt, not hostname
  name = "${var.SQL_1_name}"
  memory = "8192"
  vcpu = 2

  qemu_agent = true

  ######################### UEFI ###########################################
  #UEFI Firmware (replaces BIOS)
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"

  #UEFI RAM
  nvram {
    file = "/var/lib/libvirt/qemu/nvram/${var.SQL_1_name}_VARS.fd"
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
    hostname = "${var.SQL_1_name}"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.SQL_1_root.id
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
}

resource "time_sleep" "sql_1_init-wait_60_seconds" {
  depends_on = [ libvirt_domain.SQL_1 ]

  create_duration = "60s"
}

resource "null_resource" "join_sql_1_to_domain" {
  depends_on = [ time_sleep.sql_1_init-wait_60_seconds, time_sleep.dc_init-wait_10_minutes ]

  connection {
    type     = "winrm"
    user     = "Vagrant"
    password = "vagrant"
    host     = "${libvirt_domain.SQL_1.network_interface.0.addresses.1}"
  }
  
  # Copy the scripts
  provisioner "file" {
      source      = "./scripts/powershell/DomainClient"
      destination = "c:/windows/temp"    
  }

  provisioner "remote-exec" {
      inline = [
        "powershell.exe -ExecutionPolicy Bypass -File \"c:/Windows/Temp/add-to-domain.ps1\" -domain \"${var.domainName}\" -password \"${var.domainAdminPass}\" -domainControllerIp \"${libvirt_domain.dc.network_interface.0.addresses.1}\""
      ]
  }
}