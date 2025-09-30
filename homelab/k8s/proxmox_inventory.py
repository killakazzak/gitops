#!/usr/bin/env python3

import requests
import urllib3

# Отключаем предупреждения о SSL
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Конфигурация
PROXMOX_HOST = '192.168.1.100'
PROXMOX_USER = 'root@pam'
PROXMOX_PASSWORD = ''

def generate_simple_inventory():
    session = requests.Session()
    session.verify = False
    
    # Аутентификация
    auth_data = {'username': PROXMOX_USER, 'password': PROXMOX_PASSWORD}
    auth_url = f'https://{PROXMOX_HOST}:8006/api2/json/access/ticket'
    response = session.post(auth_url, data=auth_data)
    auth_result = response.json()
    
    if 'data' not in auth_result:
        raise Exception('Authentication failed')
    
    ticket = auth_result['data']['ticket']
    csrf_token = auth_result['data']['CSRFPreventionToken']
    
    session.headers.update({
        'CSRFPreventionToken': csrf_token,
        'Cookie': f'PVEAuthCookie={ticket}'
    })
    
    # Получаем узлы
    nodes_url = f'https://{PROXMOX_HOST}:8006/api2/json/nodes'
    nodes_response = session.get(nodes_url)
    nodes = nodes_response.json()['data']
    
    with open('inventory.ini', 'w') as f:
        f.write("# Ansible Inventory generated from Proxmox\n\n")
        
        # Группа всех хостов
        f.write("[all]\n")
        
        for node in nodes:
            node_name = node['node']
            vms_url = f'https://{PROXMOX_HOST}:8006/api2/json/nodes/{node_name}/qemu'
            vms_response = session.get(vms_url)
            
            if vms_response.status_code == 200:
                vms = vms_response.json()['data']
                
                for vm in vms:
                    if vm['status'] == 'running':
                        vm_id = vm['vmid']
                        vm_name = vm.get('name', f'vm-{vm_id}')
                        
                        # Предполагаем IP на основе ID VM (адаптируйте под вашу сеть)
                        vm_ip = f"192.168.1.{100 + vm_id}"  # Измените под вашу сетевую схему
                        
                        f.write(f"{vm_name} ansible_host={vm_ip} ")
                        f.write(f"proxmox_node={node_name} proxmox_vmid={vm_id}\n")
        
        # Группы по узлам (опционально)
        f.write("\n# Grouped by nodes\n")
        for node in nodes:
            node_name = node['node']
            f.write(f"\n[node_{node_name}]\n")
            
            vms_url = f'https://{PROXMOX_HOST}:8006/api2/json/nodes/{node_name}/qemu'
            vms_response = session.get(vms_url)
            
            if vms_response.status_code == 200:
                vms = vms_response.json()['data']
                
                for vm in vms:
                    if vm['status'] == 'running':
                        vm_name = vm.get('name', f'vm-{vm_id}')
                        f.write(f"{vm_name}\n")
        
        # Общие переменные
        f.write("\n[all:vars]\n")
        f.write("ansible_connection=ssh\n")
        f.write("ansible_user=root\n")
        f.write("ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n")

if __name__ == '__main__':
    try:
        generate_simple_inventory()
        print("Inventory file 'inventory.ini' has been generated successfully!")
        
        # Показываем содержимое файла
        with open('inventory.ini', 'r') as f:
            print("\nGenerated inventory content:")
            print(f.read())
            
    except Exception as e:
        print(f"Error: {e}")