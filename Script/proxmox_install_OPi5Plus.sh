#!/bin/bash

# Check if the script is executed as root
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

# Display a message
if command -v figlet >/dev/null 2>&1; then
    figlet -f slant "Proxmox Install"
else
    echo "Proxmox Install"
fi
echo "This script will install Proxmox VE Arm64."
echo "This script is intended for Debian Bookworm and Bullseye."
echo "This script is intended for Orange Pi 5 Plus or some Rockchip based boards."

# Check if the /proc/device-tree/compatible file exists
if [ -f /proc/device-tree/compatible ]; then
    # Use grep to check if "rockchip" is present in the file
    if grep -q "rockchip" /proc/device-tree/compatible; then
        echo "This board is Rockchip based."
    else
        echo "This board is not Rockchip based."
        exit 1
    fi
else
    echo "Unable to determine the board type."
    # Ask the user to continue
    read -rp "Continue? [y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Wait for 5 seconds
sleep 5

# Detect the distribution version
os_release_file="/etc/os-release"
if grep -q "bookworm" "$os_release_file"; then
    echo 'deb [arch=arm64] https://mirrors.apqa.cn/proxmox/debian/pve bookworm port' > /etc/apt/sources.list.d/pveport.list
elif grep -q "bullseye" "$os_release_file"; then
    echo 'deb [arch=arm64] https://mirrors.apqa.cn/proxmox/debian/pve bullseye port' > /etc/apt/sources.list.d/pveport.list
else
    echo "Distribution version not supported."
    exit 1
fi

# Download and add the Proxmox GPG key
if ! curl -fsSL https://global.mirrors.apqa.cn/proxmox/debian/pveport.gpg -o /etc/apt/trusted.gpg.d/pveport.gpg; then
    echo "Failed to download the Proxmox GPG key."
    exit 1
fi

# Update and upgrade packages with Proxmox repository
if ! apt-get update || ! apt-get full-upgrade -y; then
    echo "Failed to update and upgrade packages."
    exit 1
fi

# Install required packages
if ! apt-get install ifupdown2 proxmox-ve postfix open-iscsi -y; then
    echo "Failed to install required packages."
    exit 1
fi

# Patched edk2-firmware for Rockchip
if grep -q "bookworm" "$os_release_file"; then
    firmware_package="pve-edk2-firmware-aarch64=3.20220526-rockchip"
elif grep -q "bullseye" "$os_release_file"; then
    firmware_package="pve-edk2-firmware=3.20220526-1"
else
    echo "No patched edk2-firmware available for this distribution version."
    exit 1
fi

# Download firmware package
if ! apt-get download "$firmware_package"; then
    echo "Failed to download the firmware package."
    exit 1
fi

# Install the downloaded package
firmware_deb=$(echo "$firmware_package" | cut -d= -f1)
if ! dpkg -i "${firmware_deb}"_*.deb; then
    echo "Failed to install the firmware package."
    exit 1
fi

# Pin the package
package_version=$(echo "$firmware_package" | cut -d= -f2)
echo "Package: $firmware_deb" > /etc/apt/preferences.d/${firmware_deb}
echo "Pin: version $package_version" >> /etc/apt/preferences.d/${firmware_deb}
echo "Pin-Priority: 999" >> /etc/apt/preferences.d/${firmware_deb}

# Clean up downloaded .deb files
rm -f "${firmware_deb}"_*.deb

echo "Proxmox VE installation on arm64 is complete!"