# ===============================================================
# VM 0: NETWORK CORE (pfSense Firewall)
# ===============================================================

resource "proxmox_vm_qemu" "srv_pfsense" {
    name = "srv-pfsense-01"
    target_node = "pve-niclabs"
    vmid = 100
	description = "Firewall Principal - Suricata Enabled"

	# --- BOOT & SISTEMA ---
	onboot = true
	startup = "order=1,up=30"
    agent   = 0
    os_type = "other"
	bios = "seabios"
	
	# --- PERFORMANCE CPU ---
	cpu {
        cores = 4
        sockets = 1
        type = "host"
        numa = true
		units = 1000
    }
    
	# --- PERFORMANCE MEMÓRIA ---
    memory = 20480
    balloon = 0

	# --- ARMAZENAMENTO ---
	scsihw = "virtio-scsi-single"
	boot = "order=scsi0;ide2"

	disk {
        type = "disk"
        slot = "scsi0"
        size = "64G"
        storage = "local-zfs"
        iothread = true
        discard = true
    }

	# --- INSTALADOR ISO ---
    disk {
        type = "cdrom"
        slot = "ide2"
        iso = "local:iso/netgate-installer-v1.1-RELEASE-amd64.iso"
    }
    

    # --- REDE DE ALTA PERFORMANCE (Multiqueue Ativo) ---

    # WAN VIVO
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr1"
        firewall = false
		queues = 4
    }

    # WAN VALENET
    network {
        id = 1
        model = "virtio"
        bridge = "vmbr2"
        firewall = false
		queues = 4
    }

    # LAN TRUNK
    network {
        id = 2
        model = "virtio"
        bridge = "vmbr3"
        firewall = false
		queues = 4
    }

    # LAN LAB/VLAN
    network {
        id = 3
        model = "virtio"
        bridge = "vmbr4"
        firewall = false
		queues = 4
    }
}


# ===============================================================
# VM 1: WAZUH SIEM
# ===============================================================

resource "proxmox_vm_qemu" "srv_wazuh" {
    name        = "srv-wazuh-01"
    target_node = "pve-niclabs"
    vmid        = 105
    clone       = "ubuntu-2404-template"
    full_clone  = true
    
    agent   = 1
    os_type = "cloud-init"

    # [CORREÇÃO] Bloco CPU
    cpu {
        cores    = 10
        sockets  = 1
        type     = "host"
        numa     = true
    }

    memory  = 32768
    balloon = 0

    scsihw = "virtio-scsi-single"

    # [CORREÇÃO CRÍTICA] Disco Rígido
    disk {
        type     = "disk"      # <--- MUDOU AQUI
        slot     = "scsi0"
        size     = "100G"
        storage  = "local-zfs"
        iothread = true
        discard  = true
    }

    network {
        id     = 0
        model  = "virtio"
        bridge = "vmbr0"
    }

    ciuser    = "nic-core"
    ipconfig0 = "ip=192.168.15.200/24,gw=192.168.15.1"
    sshkeys   = join("\n", var.ssh_public_keys)
}

# ===============================================================
# VM 2: APP SERVER
# ===============================================================

resource "proxmox_vm_qemu" "srv_apps" {
    name        = "srv-apps-01"
    target_node = "pve-niclabs"
    vmid        = 106
    clone       = "ubuntu-2404-template"
    full_clone  = true
    agent       = 1
    os_type     = "cloud-init"

    # [CORREÇÃO] Bloco CPU
    cpu {
        cores    = 8
        sockets  = 1
        type     = "host"
        numa     = true
    }

    memory  = 40960
    balloon = 0

    scsihw = "virtio-scsi-single"

    disk {
        type     = "disk"
        slot     = "scsi0"
        size     = "50G"
        storage  = "local-zfs"
        iothread = true
        discard  = true
    }

    #hostpci {
        #host   = "0000:08:00"
        #rombar = 1
    #}

    network {
        id     = 0
        model  = "virtio"
        bridge = "vmbr0"
    }

    ciuser    = "nic-core"
    ipconfig0 = "ip=192.168.1.31/24,gw=192.168.1.1"
    sshkeys   = join("\n", var.ssh_public_keys)
}