variable "vm_count" {
  description = "Number of VMs to create"
  default     = 2
}

resource "proxmox_virtual_environment_vm" "vm" {
  count       = var.vm_count
  name        = format("vm-%02d", count.index + 1)
  migrate     = false
  description = "Managed by Terraform"
  #tags        = ["terraform", "production"]
  on_boot   = true
  node_name = "pve" # Static node name (single-node cluster)

  clone {
    vm_id     = "100"
    node_name = "pve" # Source node (matches target node here)
    retries   = 2
  }

  agent {
    enabled = true # Required for proper clipboard integration
  }

  operating_system {
    type = "l26" # Linux 2.6+ kernel (modern Linux OS)
  }

  cpu {
    cores = 2
    type  = "host" # Use host CPU type for better performance
    numa  = true   # Enable NUMA allocation
  }

  memory {
    dedicated = 2048 # 2GB RAM
  }

  vga {
    type   = "std" # Changed from 'serial0' to enable VNC+clipboard
    memory = 16    # Increased from 4 to recommended minimum
  }


  disk {
    size         = "40" # 40GB disk
    interface    = "virtio0"
    datastore_id = "local"
    file_format  = "raw" # Raw format for better performance
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio" # VirtIO network interface for better performance
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "dhcp" # Using DHCP for IP assignment
      }
    }
    dns {
      servers = [
        "77.88.8.8", # Yandex DNS
        "8.8.8.8"    # Google DNS
      ]
    }
    user_account {
      username = "tenda"
      keys = [
        var.ssh_public_key # Ensure this variable is defined elsewhere
      ]
    }
  }
}
