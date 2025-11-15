#!/bin/bash
# Monolith Firewall - Debian 13 (Trixie) ISO Builder
# This script builds a custom Debian 13-based ISO for the Monolith Firewall

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEBIAN_VERSION="trixie"
ISO_NAME="monolith-firewall"
ISO_VERSION="1.0.0"
ARCH="amd64"
WORK_DIR="$(pwd)/work"
ISO_OUTPUT="$(pwd)/iso-output"
CONFIG_DIR="$(pwd)/config"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Monolith Firewall ISO Builder${NC}"
echo -e "${GREEN}Debian 13 (Trixie) - ${ARCH}${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root${NC}"
    exit 1
fi

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
DEPS="debootstrap xorriso squashfs-tools isolinux syslinux-utils grub-pc-bin grub-efi-amd64-bin mtools dosfstools"
MISSING_DEPS=""

for dep in $DEPS; do
    if ! dpkg -l | grep -q "^ii  $dep "; then
        MISSING_DEPS="$MISSING_DEPS $dep"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo -e "${YELLOW}Installing missing dependencies:$MISSING_DEPS${NC}"
    apt-get update
    apt-get install -y $MISSING_DEPS
fi

# Clean up previous build
echo -e "${YELLOW}Cleaning up previous build...${NC}"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$ISO_OUTPUT"

# Create directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p "$WORK_DIR"/{chroot,iso,scratch}

# Bootstrap Debian base system
echo -e "${YELLOW}Bootstrapping Debian ${DEBIAN_VERSION} base system...${NC}"
debootstrap --arch=$ARCH $DEBIAN_VERSION "$WORK_DIR/chroot" http://deb.debian.org/debian/

# Mount necessary filesystems
echo -e "${YELLOW}Mounting filesystems...${NC}"
mount -t proc none "$WORK_DIR/chroot/proc"
mount -t sysfs none "$WORK_DIR/chroot/sys"
mount -o bind /dev "$WORK_DIR/chroot/dev"
mount -t devpts none "$WORK_DIR/chroot/dev/pts"

# Trap to ensure cleanup on exit
cleanup() {
    echo -e "${YELLOW}Cleaning up mounts...${NC}"
    umount -lf "$WORK_DIR/chroot/dev/pts" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/dev" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/sys" 2>/dev/null || true
    umount -lf "$WORK_DIR/chroot/proc" 2>/dev/null || true
}
trap cleanup EXIT

# Configure package sources
echo -e "${YELLOW}Configuring package sources...${NC}"
cat > "$WORK_DIR/chroot/etc/apt/sources.list" << EOF
deb http://deb.debian.org/debian ${DEBIAN_VERSION} main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian ${DEBIAN_VERSION} main contrib non-free non-free-firmware

deb http://deb.debian.org/debian ${DEBIAN_VERSION}-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian ${DEBIAN_VERSION}-updates main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security ${DEBIAN_VERSION}-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security ${DEBIAN_VERSION}-security main contrib non-free non-free-firmware
EOF

# Update and install packages in chroot
echo -e "${YELLOW}Installing packages in chroot environment...${NC}"
chroot "$WORK_DIR/chroot" /bin/bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends \
        linux-image-$ARCH \
        live-boot \
        systemd-sysv \
        network-manager \
        iptables \
        nftables \
        ipset \
        curl \
        wget \
        vim \
        nano \
        net-tools \
        iproute2 \
        tcpdump \
        openssh-server \
        sudo \
        less \
        bash-completion \
        ca-certificates \
        gnupg \
        apt-transport-https
"

# Install .NET runtime for Monolith Firewall
echo -e "${YELLOW}Installing .NET runtime...${NC}"
chroot "$WORK_DIR/chroot" /bin/bash -c "
    export DEBIAN_FRONTEND=noninteractive
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    apt-get update
    apt-get install -y dotnet-runtime-8.0
"

# Run custom chroot scripts if they exist
if [ -d "chroot-scripts" ]; then
    echo -e "${YELLOW}Running custom chroot scripts...${NC}"
    for script in chroot-scripts/*.sh; do
        if [ -f "$script" ]; then
            cp "$script" "$WORK_DIR/chroot/tmp/"
            chmod +x "$WORK_DIR/chroot/tmp/$(basename $script)"
            chroot "$WORK_DIR/chroot" /tmp/$(basename $script)
            rm "$WORK_DIR/chroot/tmp/$(basename $script)"
        fi
    done
fi

# Configure hostname
echo "monolith-firewall" > "$WORK_DIR/chroot/etc/hostname"

# Clean up chroot
echo -e "${YELLOW}Cleaning up chroot environment...${NC}"
chroot "$WORK_DIR/chroot" /bin/bash -c "
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    rm -rf /tmp/*
    rm -rf /var/tmp/*
"

# Create the ISO structure
echo -e "${YELLOW}Creating ISO structure...${NC}"
mkdir -p "$WORK_DIR/iso"/{live,isolinux,boot/grub}

# Create squashfs filesystem
echo -e "${YELLOW}Creating squashfs filesystem...${NC}"
mksquashfs "$WORK_DIR/chroot" "$WORK_DIR/iso/live/filesystem.squashfs" -comp xz -b 1M

# Copy kernel and initrd
echo -e "${YELLOW}Copying kernel and initrd...${NC}"
cp "$WORK_DIR/chroot/boot"/vmlinuz-* "$WORK_DIR/iso/live/vmlinuz"
cp "$WORK_DIR/chroot/boot"/initrd.img-* "$WORK_DIR/iso/live/initrd"

# Configure isolinux for BIOS boot
echo -e "${YELLOW}Configuring ISOLINUX...${NC}"
cp /usr/lib/ISOLINUX/isolinux.bin "$WORK_DIR/iso/isolinux/"
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$WORK_DIR/iso/isolinux/"
cp /usr/lib/syslinux/modules/bios/menu.c32 "$WORK_DIR/iso/isolinux/"
cp /usr/lib/syslinux/modules/bios/libutil.c32 "$WORK_DIR/iso/isolinux/"

cat > "$WORK_DIR/iso/isolinux/isolinux.cfg" << 'EOF'
DEFAULT menu.c32
PROMPT 0
TIMEOUT 100

MENU TITLE Monolith Firewall Boot Menu

LABEL live
    MENU LABEL ^Start Monolith Firewall
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live quiet splash

LABEL live-fail
    MENU LABEL Start Monolith Firewall (^failsafe mode)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live config memtest noapic noacpi edd=on nomodeset
EOF

# Configure GRUB for UEFI boot
echo -e "${YELLOW}Configuring GRUB for UEFI...${NC}"
cat > "$WORK_DIR/iso/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "Start Monolith Firewall" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}

menuentry "Start Monolith Firewall (failsafe mode)" {
    linux /live/vmlinuz boot=live config memtest noapic noacpi edd=on nomodeset
    initrd /live/initrd
}
EOF

# Create EFI boot image
echo -e "${YELLOW}Creating EFI boot image...${NC}"
mkdir -p "$WORK_DIR/iso/EFI/boot"
grub-mkstandalone \
    --format=x86_64-efi \
    --output="$WORK_DIR/iso/EFI/boot/bootx64.efi" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$WORK_DIR/iso/boot/grub/grub.cfg"

# Create ISO
echo -e "${YELLOW}Creating ISO image...${NC}"
ISO_FILE="$ISO_OUTPUT/${ISO_NAME}-${ISO_VERSION}-${ARCH}.iso"

xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "MONOLITH_FIREWALL" \
    -eltorito-boot isolinux/isolinux.bin \
    -eltorito-catalog isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-alt-boot \
    -e EFI/boot/bootx64.efi \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -output "$ISO_FILE" \
    "$WORK_DIR/iso"

# Generate checksums
echo -e "${YELLOW}Generating checksums...${NC}"
cd "$ISO_OUTPUT"
sha256sum "$(basename $ISO_FILE)" > "${ISO_NAME}-${ISO_VERSION}-${ARCH}.sha256"
md5sum "$(basename $ISO_FILE)" > "${ISO_NAME}-${ISO_VERSION}-${ARCH}.md5"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}ISO build completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "ISO file: ${GREEN}$ISO_FILE${NC}"
echo -e "Size: $(du -h $ISO_FILE | cut -f1)"
echo -e "SHA256: $(cat ${ISO_NAME}-${ISO_VERSION}-${ARCH}.sha256)"
echo -e "${GREEN}========================================${NC}"
