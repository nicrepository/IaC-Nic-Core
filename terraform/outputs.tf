resource "local_file" "ansible_inventory" {
  content = <<EOF

  [firewalls]
  # IP da LAN Gerência (vmbr0) definido na instalação
  10.10.10.1 ansible_user=admin ansible_password='SUA_SENHA_FORTE'

  [siem]
  # IP definido no main.tf (srv_wazuh)
  10.10.10.3 ansible_user=nic-core ansible_ssh_private_key_file=~/.ssh/id_rsa

  [apps]
  # IP definido no main.tf (srv_apps)
  10.10.10.4 ansible_user=nic-core ansible_ssh_private_key_file=~/.ssh/id_rsa
  EOF
  filename = "../ansible/inventory.ini"
}