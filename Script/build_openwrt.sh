#!/bin/bash

# Install Dependencies
sudo apt update
sudo apt install build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev \
libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
python3-distutils python3-setuptools python3-dev rsync subversion \
swig time xsltproc zlib1g-dev 

# Download the Source Code
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
git tag
git checkout v23.05.2
./scripts/feeds update -a

# Configure the Project
# Import the official configuration.
wget 
cp config.buildinfo .config

# Add UEFI ACPI support.
# Open file target/linux/armvirt/config-5.4, and append the following lines to the end of file.
echo "CONFIG_EFI_STUB=y" >> target/linux/armvirt/config-5.4
echo "CONFIG_EFI=y" >> target/linux/armvirt/config-5.4
echo "CONFIG_EFI_VARS=y" >> target/linux/armvirt/config-5.4
echo "CONFIG_ARCH_SUPPORTS_ACPI=y" >> target/linux/armvirt/config-5.4
echo "CONFIG_ACPI=y" >> target/linux/armvirt/config-5.4

# Launch Memuconfig.
make menuconfig
make kernel_menuconfig
