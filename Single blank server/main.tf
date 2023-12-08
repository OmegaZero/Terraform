terraform {
  required_providers {
    # see https://registry.terraform.io/providers/hashicorp/random
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    # see https://registry.terraform.io/providers/hashicorp/template
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    # see https://registry.terraform.io/providers/dmacvicar/libvirt
    # see https://github.com/dmacvicar/terraform-provider-libvirt
    # 0.7.4 has issues with qemu+ssh 
    # see https://github.com/dmacvicar/terraform-provider-libvirt/issues/1040
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1" 
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://elementzero@192.168.75.50/system?keyfile=/home/elementzero/.ssh/id_ed25519&sshauth=privkey"
}




