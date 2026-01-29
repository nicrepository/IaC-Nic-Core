terraform {
	required_providers {
		proxmox = {
			source = "Telmate/proxmox"
      		version = "3.0.2-rc07"
		}
	}
}

provider "proxmox" {
	pm_api_url = var.proxmox_api_url
	pm_api_token_id = var.proxmox_token_id
	pm_api_token_secret = var.proxmox_token_secret

	pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.

	# Debug otimization
	# pm_log_enable = true
	# pm_log_file = "terraform-plugin-proxmox.log"
}