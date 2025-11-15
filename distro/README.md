# Monolith Firewall - Debian 13 (Trixie) Distribution Builder

This directory contains scripts and configuration files to build a custom Debian 13-based ISO for the Monolith Firewall.

## Prerequisites

You need to run the build script on a Debian-based system (Debian 11+, Ubuntu 20.04+) with root access.

The build script will automatically install required dependencies:
- debootstrap
- xorriso
- squashfs-tools
- isolinux
- syslinux-utils
- grub-pc-bin
- grub-efi-amd64-bin
- mtools
- dosfstools

## Directory Structure

- `build-iso.sh` - Main ISO builder script
- `scripts/` - Helper scripts for ISO customization
- `config/` - Configuration files (package lists, etc.)
- `packages/` - Custom .deb packages to include
- `chroot-scripts/` - Scripts to run inside the chroot environment
- `iso-output/` - Final ISO files will be placed here

## Building the ISO

1. Make the build script executable:
   ```bash
   chmod +x build-iso.sh
   ```

2. Run the build script as root:
   ```bash
   sudo ./build-iso.sh
   ```

3. The ISO will be created in the `iso-output/` directory

## Customization

### Adding Packages

Edit the package installation section in `build-iso.sh` or create a custom script in `chroot-scripts/` directory.

### Custom Scripts

Place any `.sh` scripts in the `chroot-scripts/` directory. These will be executed inside the chroot environment during the build process.

### Boot Configuration

Modify the ISOLINUX and GRUB configurations in `build-iso.sh` to customize the boot menu.

## Build Output

After a successful build, you'll find:
- `monolith-firewall-{version}-amd64.iso` - The bootable ISO image
- `monolith-firewall-{version}-amd64.sha256` - SHA256 checksum
- `monolith-firewall-{version}-amd64.md5` - MD5 checksum

## Testing

Test the ISO using:
- VirtualBox
- QEMU: `qemu-system-x86_64 -cdrom iso-output/monolith-firewall-*.iso -m 2048 -enable-kvm`
- VMware
- Physical hardware (write to USB with `dd` or Rufus/Etcher)

## Notes

- The build process requires significant disk space (8-10 GB minimum)
- Build time depends on your internet connection and system performance (typically 15-30 minutes)
- The resulting ISO supports both BIOS and UEFI boot modes
