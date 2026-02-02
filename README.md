# 🛡️ Nic-Core Shield (IaC)

Repositório central de Infraestrutura como Código da **Nic-Labs**. Este projeto gerencia o ciclo de vida completo dos servidores, desde o provisionamento de VMs no Proxmox até a configuração de serviços de segurança e aplicações.

## 🏗️ Arquitetura

O projeto é desenhado para rodar em hardware Bare Metal (Ryzen 9 5900X) com Proxmox VE.

| VM ID | Hostname | Função | Specs (vCPU/RAM) | IP Fixo |
| :--- | :--- | :--- | :--- | :--- |
| **100** | `srv-pfsense-01` | Firewall, Gateway & VLANs | 4 vCPU / 20GB | 192.168.50.1 |
| **105** | `srv-wazuh-01` | SIEM, Logs & Security | 10 vCPU / 32GB | 192.168.50.10 |
| **106** | `srv-apps-01` | Docker, Vaultwarden & Tools | 8 vCPU / 40GB | 192.168.50.11 |

**Tecnologias:**
* **Hypervisor:** Proxmox VE (KVM/LXC)
* **Provisionamento:** Terraform (Provider: `telmate/proxmox`)
* **Configuração:** Ansible
* **OS Base:** Ubuntu Server 24.04 LTS (Cloud-Init) & pfSense CE

## 🚀 Como Utilizar

### Pré-requisitos
1.  Ter acesso VPN ou local à rede de Gerência (10.10.10.x).
2.  Ter o **Terraform** e **Ansible** instalados no local de controle (WSL/Linux).
3.  Possuir o Token de API do Proxmox.

### 1. Configuração de Credenciais
Crie um arquivo `terraform/credentials.auto.tfvars` (ele é ignorado pelo Git) com o seguinte conteúdo:

```hcl
proxmox_api_url      = "[https://10.10.10.2:8006/api2/json](https://10.10.10.2:8006/api2/json)"
proxmox_token_id     = "root@pam!terraform"
proxmox_token_secret = "SEU-UUID-SECRETO-AQUI"
ssh_public_keys      = [
  "ssh-rsa AAAAB3... (Chave Alvaro)",
  "ssh-rsa AAAAB3... (Chave Caio)"
]
```

### 2. Provisionando Infraestrutura (Terraform)
```
cd terraform
terraform init
terraform plan  # Verifique o plano de execução
terraform apply # Aplica a criação das VMs
```
Isso criará automaticamente o arquivo ../ansible/inventory.ini.

### 3. Configurando os Servidores (Ansible)
```
cd ansible
ansible -i inventory.ini all -m ping # Teste de conexão
ansible-playbook -i inventory.ini site.yml
```

## 📂 Estrutura do Projeto
```
.
├── ansible/                # Configuração de Software
│   ├── roles/              # Funções (Docker, Security, Common)
│   ├── site.yml            # Playbook Principal
│   └── inventory.ini       # Gerado automaticamente
├── terraform/              # Infraestrutura (VMs)
│   ├── main.tf             # Definição das VMs
│   ├── provider.tf         # Conexão Proxmox
│   └── variables.tf        # Definição de Variáveis
└── README.md               # Documentação
```
