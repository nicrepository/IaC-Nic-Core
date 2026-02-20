# ===============================================================
# VM 0: NETWORK CORE (pfSense Firewall)
# ===============================================================
# EXECUTAR ANTES: 
# echo 'hw.vtnet.mq_disable=0' >> /boot/loader.conf.local
# echo 'hw.vtnet.max_virtqueues=4' >> /boot/loader.conf.local

resource "proxmox_vm_qemu" "srv_opnsense" {
    name = "srv-opnsense-01"
    target_node = "nic-labs"
    vmid = 100
	description = "Firewall Principal Nic-Labs (OPNsense)"

	# --- SISTEMA ---
    agent = 0
    os_type = "other"
	bios = "ovmf"
    machine = "q35"
    tablet = false

    efidisk {
        storage = "local-zfs"
        efitype    = "4m"
    }

	# --- BOOT ---
	start_at_node_boot = true
	startup_shutdown {
		order = 1
		startup_delay = 30
		shutdown_timeout = 0
	}
	
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
        size = "50G"
        storage = "local-zfs"
        iothread = true
        discard = true
    }

	# --- INSTALADOR ISO ---
    disk {
        type = "cdrom"
        slot = "ide2"
        iso = "local:iso/OPNsense-26.1.2-dvd-amd64.iso"
    }
    
    # --- VGA ---
    vga {
        type = "std"
    }

    # --- REDE DE ALTA PERFORMANCE (Multiqueue Ativo) ---
    network {
        id       = 0
        model    = "virtio"
        bridge   = "vmbr0"
        firewall = false
        queues   = 4
    }

    # --- REDE: PCI PASSTHROUGH VIA RESOURCE MAPPING ---
    pcis {
        # Porta 1 - WAN Vivo
        pci0 {
            mapping {
                mapping_id = "nic-wan-vivo"
                pcie       = false
                rombar     = false
            }
        }
        
        # Porta 2 - WAN Valenet
        pci1 {
            mapping {
                mapping_id = "nic-wan-valenet"
                pcie       = false
                rombar     = false
            }
        }

        # Porta 3 - LAN Trunk (VLANs)
        pci2 {
            mapping {
                mapping_id = "nic-lan-trunk"
                pcie       = false
                rombar     = false
            }
        }

        # Porta 4 - LAN Lab / Extra
        pci3 {
            mapping {
                mapping_id = "nic-lan-lab"
                pcie       = false
                rombar     = false
            }
        }
    }
}


# ===============================================================
# VM 1: WAZUH SIEM
# ===============================================================

resource "proxmox_vm_qemu" "srv_wazuh" {
    name = "srv-wazuh-01"
    target_node = "nic-labs"
    vmid = 105
	description = "SIEM & XDR - OpenSearch Database"

	# --- CLONAGEM TEMPLATE ---
    clone = "ubuntu-2404-template"
    full_clone = true
    
	# --- SISTEMA ---
    agent = 1
    os_type = "cloud-init"
	bios = "seabios"

	# --- BOOT ---
	start_at_node_boot = true
	startup_shutdown {
		order = 2
		startup_delay = 60
		shutdown_timeout = 0
	}

	# --- PERFORMANCE CPU ---
    cpu {
        cores = 10
        sockets = 1
        type = "host"
        numa = true
		flags {
			aes = "on"
		}
    }

	# --- PERFORMANCE MEMÓRIA ---
    memory = 32768
    balloon = 0

	# --- ARMAZENAMENTO ---
	scsihw = "virtio-scsi-single"


	# DISCO 1: Sistema
    disk {
        type = "disk"
        slot = "scsi0"
        size = "300G"
        storage = "local-zfs"
        iothread = true
        discard = true
    }

    disk {
        type = "cloudinit"
        slot = "ide0"
        storage = "local-zfs"
    }

	# --- REDE ---
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
		firewall = false
    }

    # --- VGA ---
    vga {
        type = "std"
    }

	# --- CLOUD-INIT ---
    ciuser = "nic-core"
    ipconfig0 = "ip=10.10.10.3/24,gw=10.10.10.1"
    sshkeys = join("\n", var.ssh_public_keys)
}

# ===============================================================
# VM 2: APP SERVER
# ===============================================================

resource "proxmox_vm_qemu" "srv_apps" {
    name = "srv-apps-01"
    target_node = "nic-labs"
    vmid = 106
	description = "App server"

    # --- CLONAGEM TEMPLATE ---
    clone = "ubuntu-2404-template"
    full_clone = true

    # --- SISTEMA ---
    agent = 1
    os_type = "cloud-init"
	bios = "seabios"

	# --- BOOT ---
	start_at_node_boot = true
	startup_shutdown {
		order = 3
		startup_delay = 60
		shutdown_timeout = 0
	}

    # --- PERFORMANCE CPU ---
    cpu {
        cores = 8
        sockets = 1
        type = "host"
        numa = true
    }

	# --- PERFORMANCE MEMÓRIA ---
    memory = 40960
    balloon = 0

	# --- ARMAZENAMENTO ---
    scsihw = "virtio-scsi-single"

	# DISCO 1: Sistema
    disk {
        type = "disk"
        slot = "scsi0"
        size = "350G"
        storage = "local-zfs"
        iothread = true
        discard = true
    }

    disk {
        type = "cloudinit"
        slot = "ide0"
        storage = "local-zfs"
    }

	# --- GPU PASSTHROUGH ---
    machine = "q35"
	pcis {
		pci0 {
			mapping {
				mapping_id = "nvidia-rtx4060"
				pcie = true
				rombar = true
				primary_gpu = false
			}
		}
	}

	# --- REDE ---
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
		firewall = false
    }

    # --- VGA ---
    vga {
        type = "std"
    }

	# --- CLOUD-INIT ---
    ciuser    = "nic-core"
    ipconfig0 = "ip=10.10.10.4/24,gw=10.10.10.1"
    sshkeys   = join("\n", var.ssh_public_keys)
}