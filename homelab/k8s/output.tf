output "vm_basic_info" {
  value = {
    control_vms = [for vm in proxmox_virtual_environment_vm.control_vm : {
      name = vm.name
      id   = vm.id
    }]
    worker_vms = [for vm in proxmox_virtual_environment_vm.worker_vm : {
      name = vm.name
      id   = vm.id
    }]
  }
}
