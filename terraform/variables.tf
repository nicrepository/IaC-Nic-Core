variable "proxmox_api_url" {
	type = string
	description = "Endpoint da API (Ex: https://10.10.10.2:8006/api2/json)"
}

variable "proxmox_token_id" {
	type = string
	sensitive = true
}

variable "proxmox_token_secret" {
	type = string
	sensitive = true
}


variable "ssh_public_keys" {
	type = list(string)
	description = "Lista de chaves públicas"
}

variable "target_node" {
	type = string
	default = "pve_nic-labs"
}