#!/bin/bash

# Function to display the list of disks
list_disks() {
  echo "Available disks:"
  ls -n /dev/disk/by-id/
}

# Function to get the serial number of a disk
get_serial() {
  lsblk -o NAME,SIZE,MODEL,SERIAL | grep "$1" | awk '{print $4}'
}

# Function to update Proxmox configuration
update_proxmox_config() {
  local vmid=$1
  local scsi_id=$(( $(qm config $vmid | grep scsi | wc -l) + 1 ))
  local disk_id=$2
  local serial_number=$3

  qm set $vmid --scsi$scsi_id /dev/disk/by-id/$disk_id
  echo "scsi$scsi_id: /dev/disk/by-id/$disk_id,serial=$serial_number" >> /etc/pve/qemu-server/$vmid.conf
}

# Main script
list_disks

# Ask user for disk selection
read -p "Enter the disk ID to pass through (e.g., nvme-SPCC_M.2_PCIe_SSD_296E079A0F3700255563): " disk_id

# Ask user for VM selection
read -p "Enter the VM ID to pass the disk to: " vmid

# Get the serial number of the selected disk
serial_number=$(get_serial $disk_id)

# Confirm the user's choices
echo "Selected Disk: $disk_id (Serial: $serial_number)"
echo "VM ID: $vmid"

# Ask for confirmation
read -p "Do you want to proceed? (y/n): " choice
if [ "$choice" != "y" ]; then
  echo "Aborted."
  exit 0
fi

# Update Proxmox configuration
update_proxmox_config $vmid $disk_id $serial_number

echo "Disk passed through successfully to VM $vmid."
