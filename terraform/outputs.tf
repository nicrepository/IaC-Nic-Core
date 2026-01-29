resource "local_file" "ansible_inventory" {
  content = <<EOF

  [firewalls]
  # IP fixo manual, pois o pfSense não tem agente QEMU ativo para reportar IP
  192.168.50.1 ansible_user=admin ansible_password=pfsense # Senha padrao, mude logo!

  [siem]
  ${proxmox_vm_qemu.srv_wazuh.default_ipv4_address} ansible_user=nic-core ansible_ssh_private_key_file=~/.ssh/id_rsa

  [apps]
  ${proxmox_vm_qemu.srv_apps.default_ipv4_address} ansible_user=nic-core ansible_ssh_private_key_file=~/.ssh/id_rsa
  EOF
  filename = "./inventory.ini"
}