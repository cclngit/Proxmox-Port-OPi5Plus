# Troubleshooting Guide: Display Initialization Error

If you encounter the error "Guest has not initialized the display (yet)" or any other display-related issue, follow these steps to resolve it:

1. Check Proxmox VE Version:
   ```bash
   pveversion --verbose
   ```

    Look for the line that says "pve-edk2-firmware" and check the version number. If the version number is not "3.20220526-rockchip", you need to update the firmware. You may also see "pve-edk2-firmware: not correctly installed" if the firmware is not installed.

2. Download the Updated Firmware:
   ```bash
   sudo apt download pve-edk2-firmware-aarch64=3.20220526-rockchip
   ```

3. Install the Firmware:
   ```bash
   sudo dpkg -i pve-edk2-firmware-aarch64_3.20220526-rockchip_all.deb
   ```

4. Verify Proxmox VE Version After Installation:
   ```bash
   pveversion --verbose
   ```
    The version number should now be "3.20220526-rockchip". If it is not, you may need to set package pinning.

5. Set Package Pinning (Prevent Unintended Upgrades):
   ```bash
   sudo echo 'Package: pve-edk2-firmware
   Pin: version 3.20220526-rockchip
   Pin-Priority: 999' > /etc/apt/preferences.d/pve-edk2-firmware
   ```
6. Verify Package Pinning:
   ```bash
   cat /etc/apt/preferences.d/pve-edk2-firmware
   ```

execute `pveversion --verbose` again to verify the version number. It should be "3.20220526-rockchip". If it is not, you may need to reboot the system. If the issue persists, try to star the VM again, if it works, you are done.

Note: Ensure you have the necessary permissions to execute these commands. If you face any issues, refer to the Proxmox-Port documentation or seek assistance from the community forums. https://github.com/jiangcuo/Proxmox-Port/wiki