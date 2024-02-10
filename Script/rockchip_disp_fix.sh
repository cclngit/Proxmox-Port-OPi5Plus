# Title: Fix for Rockchip display issues in Proxmox VE 7.0
#!/bin/bash

os_release_file="/etc/os-release"

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