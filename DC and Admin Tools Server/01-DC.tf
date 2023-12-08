# volume to attach to the domain as main disk
resource "libvirt_volume" "dc_root" {
  name           = "${var.DC_name}-root.qcow2"
  base_volume_id = libvirt_volume.base-image.id
}

resource "libvirt_domain" "dc" {
  # domain name in libvirt, not hostname
  name = "${var.DC_name}"
  memory = "4096"
  vcpu = 1

  qemu_agent = true

  ######################### UEFI ###########################################
  #UEFI Firmware (replaces BIOS)
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"

  #UEFI RAM
  nvram {
    file = "/var/lib/libvirt/qemu/nvram/${var.DC_name}_VARS.fd"
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

  # network_interface {
  #   network_id     = libvirt_network.mytest_network.id
  #   #mac            = "52:54:00:6C:3C:02"
  #   addresses      = ["192.168.75.100"]
  #   hostname       = "win10_terraform_01"
  #   wait_for_lease = true
  # }

  network_interface {
    bridge ="br0"
    mac = "52:54:00:12:52:cc"
    hostname       = "${var.DC_name}"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.dc_root.id
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

#Wait for two minutes as the machine is on but has not yet finished doing initial config
resource "time_sleep" "dc_init-wait_2_minutes" {
  depends_on = [ libvirt_domain.dc ]

  create_duration = "2m"
}

resource "null_resource" "change_domain_admin_password" {

  depends_on = [ time_sleep.dc_init-wait_2_minutes ]

  connection {
    type     = "winrm"
    user     = "Vagrant"
    password = "vagrant"
    host     = "${libvirt_domain.dc.network_interface.0.addresses.1}"
  }

  provisioner "remote-exec" {
      inline = [
        "net user vagrant \"${var.domainAdminPass}\"",
        "net user Administrator \"${var.domainAdminPass}\"",
        "net user Administrator /active:no"        
      ]
  }  
}

resource "null_resource" "dc_change_server_name" {

  depends_on = [ null_resource.change_domain_admin_password ]

  connection {
    type     = "winrm"
    user     = "Vagrant"
    password = "${var.domainAdminPass}"
    host     = "${libvirt_domain.dc.network_interface.0.addresses.1}"
  }

  provisioner "remote-exec" {
      inline = [
        "powershell.exe -ExecutionPolicy Bypass -Command \"Rename-Computer -NewName '${var.DC_name}' -Force -Restart\""
      ]
      on_failure = continue
  }
}

resource "null_resource" "setup_dc" {

  depends_on = [ null_resource.dc_change_server_name ]

  connection {
    type     = "winrm"
    user     = "Vagrant"
    password = "${var.domainAdminPass}"
    host     = "${libvirt_domain.dc.network_interface.0.addresses.1}"
  }
  
  # Copy the scripts
  provisioner "file" {
      source      = "./scripts/powershell/DomainController/"
      destination = "c:/windows/temp"    
  }

  
  provisioner "remote-exec" {
      inline = [
        "powershell.exe -ExecutionPolicy Bypass -File \"c:/Windows/Temp/Install-DomainServices.ps1\"",
        "powershell.exe -ExecutionPolicy Bypass -File \"c:/Windows/Temp/Install-ADDSForest.ps1\" -domainName \"${var.domainName}\" -domainNetbiosName \"${var.domainNetbiosName}\" -safeModePass \"${var.domainSafeModePass}\"",
      ]
  }
  
  provisioner "remote-exec" {
      inline = [
        "shutdown /r /f /t 5 /c \"forced reboot\"",
        "net stop WinRM"
      ]
      # Terraform > v0.11.3 will fail if the provisioner doesn't report the exit status, but here we'll explicitly allow failure
      on_failure = continue
  }
}

#Wait 10 minutes as it takes a while to reconfigure the server as a domain controller after rebooting
resource "time_sleep" "dc_init-wait_10_minutes" {
  depends_on = [ null_resource.setup_dc ]

  create_duration = "10m"
}

resource "null_resource" "create_dc_admin" {

  depends_on = [ time_sleep.dc_init-wait_10_minutes ]

  connection {
    type     = "winrm"
    user     = "Vagrant"
    password = "${var.domainAdminPass}"
    host     = "${libvirt_domain.dc.network_interface.0.addresses.1}"
  }

  provisioner "remote-exec" {
      inline = [
        "powershell.exe -ExecutionPolicy Bypass -File \"c:/Windows/Temp/New-ADUser.ps1\" -server localhost -user \"${var.domainAccountUser}\" -password \"${var.domainAccountPassword}\" -domainName \"${var.domainName}\"",
        "net localgroup administrators /add adam /domain"
      ]
  }
}
