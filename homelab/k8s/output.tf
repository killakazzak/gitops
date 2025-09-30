# outputs.tf

output "vm_basic_info" {
  description = "Basic information about created VMs"
  value = {
    for vm in proxmox_virtual_environment_vm.vm :
    vm.name => {
      id   = vm.id
      node = vm.node_name
      name = vm.name
    }
  }
}
