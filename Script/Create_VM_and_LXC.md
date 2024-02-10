# Proxmox Virtual Machine and LXC Container Setup Guide

## Creating a VM Template with UEFI Firmware (Without VirtIO Disk)

To create a VM template with UEFI firmware and without VirtIO disk, use the following command:

```bash
qm create <VMID> \
  --name <VM_NAME> \
  --agent 1 \
  --bios ovmf \
  --boot order=net0 \
  --cores 4 \
  --cpu host \
  --efidisk0 local:100/base-100-disk-0.qcow2,efitype=4m,pre-enrolled-keys=1,size=64M \
  --memory 4096 \
  --net0 virtio=BC:24:11:0D:8B:DA,bridge=vmbr0,firewall=1 \
  --numa 0 \
  --ostype l26 \
  --scsihw virtio-scsi-single \
  --smbios1 uuid=fbad4733-7d8c-4ec0-bf2b-0a397cbeea6a \
  --sockets 1 \
  --template 1 \
  --vcpus 4 \
  --affinity 4,5,6,7
```

After creating the template, you can clone it to create a new VM using:

```bash
qm clone <VMID> <NEW_VMID> --name <NEW_VM_NAME>
```

or use the Proxmox GUI.

## Importing a UEFI ARM Linux Image

Before importing a UEFI ARM Linux image, download it to the `/var/lib/vz/template/iso/` directory or via Proxmox GUI in `<STORAGE>` -> ISO Images.

```bash
qm importdisk <NEW_VMID> /var/lib/vz/template/iso/uefi-linux-arm64.img <STORAGE> --format qcow2
```

After importing, you may need to resize the disk using the Proxmox GUI, adjust settings, and start the VM.

## Creating an LXC Container

1. Download the rootfs tarball from [Linux Containers Images](https://images.linuxcontainers.org/images/).

2. Create the LXC container using the following command:

```bash
pct create <LXC_ID> ./rootfs.tar.xz --unprivileged 1 --ostype unmanaged --hostname <LXC_NAME> --net0 name=eth0 --net1 name=eth1 --storage <STORAGE> --arch arm64
```

Note: Change LXC_ID, LXC_NAME, STORAGE, and network bridge names accordingly. Follow specific image instructions if needed.

3. Edit the LXC container configuration:

```bash
nano /etc/pve/lxc/<LXC_ID>.conf
```

Feel free to customize these commands according to your specific requirements.