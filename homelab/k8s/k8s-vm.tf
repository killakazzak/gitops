variable "control_vm_count" {
  description = "Number of control VMs to create"
  default     = 3
}

variable "worker_vm_count" {
  description = "Number of worker VMs to create"
  default     = 3
}

resource "proxmox_virtual_environment_vm" "control_vm" {
  count       = var.control_vm_count
  name        = format("control-%02d", count.index + 1)
  migrate     = false
  description = "Managed by Terraform"
  on_boot     = true
  node_name   = "pve"

  clone {
    vm_id     = "100"
    node_name = "pve"
    retries   = 2
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 8
    type  = "host"
    numa  = true
  }

  memory {
    dedicated = 8192
  }

  vga {
    type   = "std"
    memory = 16
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    dns {
      servers = [
        "77.88.8.8",
        "8.8.8.8"
      ]
    }
    user_account {
      username = "tenda"
      keys = [
        var.ssh_public_key
      ]
    }
  }
}

resource "proxmox_virtual_environment_vm" "worker_vm" {
  count       = var.worker_vm_count
  name        = format("worker-%02d", count.index + 1)
  migrate     = false
  description = "Managed by Terraform"
  on_boot     = true
  node_name   = "pve"

  clone {
    vm_id     = "100"
    node_name = "pve"
    retries   = 2
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 8
    type  = "host"
    numa  = true
  }

  memory {
    dedicated = 8192
  }

  vga {
    type   = "std"
    memory = 16
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    dns {
      servers = [
        "77.88.8.8",
        "8.8.8.8"
      ]
    }
    user_account {
      username = "tenda"
      keys = [
        var.ssh_public_key
      ]
    }
  }
}
