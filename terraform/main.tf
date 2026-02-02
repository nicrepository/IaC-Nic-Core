# ===============================================================
# VM 0: NETWORK CORE (pfSense Firewall)
# ===============================================================

resource "proxmox_vm_qemu" "srv_pfsense" {
    name = "srv-pfsense-01"
    target_node = var.target_node
    vmid = 100
    
    iso = "local:iso/pfSense-CE-2.7.2-RELEASE-amd64.iso"
    
    agent = 0
    os_type = "other"

    # --- PERFORMANCE CPU ---
    cores = 4
    sockets = 1
    cpu = "host"
    numa = true

    # --- PERFORMANCE MEMÓRIA ---
    memory = 20480
    balloon = 0

    # --- ARMAZENAMENTO ---
    scsihw = "virtio-scsi-single"
    disk {
        slot = 0
        size = "32G"
        type = "scsi"
        storage = "local-zfs"
        iothread = 1
        discard = "on"
        ssd = 1
    }

    # --- REDE (4 Interfaces Físicas) ---
    
    # WAN VIVO
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr1"
        firewall = false
    }

    # WAN VALENET
    network {
        id  = 1
        model = "virtio"
        bridge = "vmbr2"
        firewall = false
    }

    # LAN TRUNK (VLANs)
    network {
        id  = 2
        model = "virtio"
        bridge = "vmbr3"
        firewall = false
    }

    # LAN LAB
    network {
        id = 3
        model = "virtio"
        bridge = "vmbr4"
        firewall = false
    }

    boot = "order=scsi0;ide2"
}


# ===============================================================
# VM 1: WAZUH SIEM (Monitoramento & Segurança)
# ===============================================================

resource "proxmox_vm_qemu" "srv_wazuh" {
	name = "srv-wazuh-01"
	target_node = var.target_node
	vmid = 105
	clone = "ubuntu-2404-template"
	
	# Agente QEMU: Permite ao Proxmox ver IP e RAM da VM
	agent = 1
	os_type = "cloud-init"

	# --- PERFORMACE CPU ---
	cores = 10
	sockets = 1
	cpu = "host"
	numa = true


	# --- PERFORMACE MEMORIA ---
	memory = 32768
	balloon = 0

	# --- STORAGE NVMe ZFS ---
	scsihw = "virtio-scsi-single"
	disk {
		slot = 0
		size = "350G"
		type = "scsi"
		storage = "local-zfs"
		iothread = 1
		discard = "on"
		ssd = 1
	}

	# --- REDE & SEGURANÇA
	network {
		model = "virtio"
		bridge = "vmbr3"
		tag = 50
	}

	# --- CLOUD-INIT ---
	ciuser = "nic-core"
	ipconfig0 = "ip=192.168.50.10/24,gw=192.168.50.1"
	sshkeys = <<EOF
	${join("\n", var.ssh_public_keys)}
	EOF
}

# ===============================================================
# VM 2: APP SERVER
# ===============================================================

resource "proxmox_vm_qemu" "srv_apps" {
	name = "srv-apps-01"
	target_node = var.target_node
	vmid = 106
	clone = "ubuntu-2404-template"
	agent = 1
	os_type = "cloud-init"

	# --- PERFORMACE CPU ---
	cores = 8
	sockets = 1
	cpu = "host"
	numa = true

	# --- PERFORMACE MEMORIA ---
	memory = 40960
	balloon = 0

	# --- STORAGE NVMe ZFS ---
	scsihw = "virtio-scsi-single"
	disk {
		slot = 0
		size = "400G"
		type = "scsi"
		storage = "local-zfs"
		iothread = 1
		discard = "on"
		ssd = 1
	}

	# PASSTHROUGH GPU
    hostpci {
        pci = "0000:01:00"  # <--- Confirme este ID com 'lspci' no Host
        rombar = 1
        xrom = 1
		# Adicione isso se tiver problemas:
		# pcie = 1
    }

	# --- REDE & SEGURANÇA
	network {
		model = "virtio"
		bridge = "vmbr3"
		tag = 50
	}

	# --- CLOUD-INIT ---
	ciuser = "nic-core"
	ipconfig0 = "ip=192.168.50.11/24,gw=192.168.50.1"
	sshkeys = <<EOF
	${join("\n", var.ssh_public_keys)}
	EOF
}