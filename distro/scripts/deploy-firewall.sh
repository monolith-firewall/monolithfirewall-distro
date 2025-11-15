#!/bin/bash
# Monolith Firewall - Deployment Script
# Deploys the compiled Monolith Firewall binary to the ISO chroot

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build/release"
CHROOT_TARGET="/opt/monolith-firewall/bin"

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found at $BUILD_DIR"
    echo "Please build the project first"
    exit 1
fi

# This script should be called during ISO build or for manual deployment
if [ -z "$1" ]; then
    echo "Usage: $0 <chroot-path>"
    echo "Example: $0 /path/to/chroot"
    exit 1
fi

CHROOT_PATH="$1"

if [ ! -d "$CHROOT_PATH" ]; then
    echo "Error: Chroot path not found: $CHROOT_PATH"
    exit 1
fi

echo "Deploying Monolith Firewall to $CHROOT_PATH$CHROOT_TARGET"

# Create target directory in chroot
mkdir -p "$CHROOT_PATH$CHROOT_TARGET"

# Copy binaries
if [ -f "$BUILD_DIR/MonolithFirewall" ]; then
    cp -v "$BUILD_DIR"/* "$CHROOT_PATH$CHROOT_TARGET/"
    chmod +x "$CHROOT_PATH$CHROOT_TARGET/MonolithFirewall"
    echo "Deployment completed successfully!"
else
    echo "Error: MonolithFirewall binary not found in $BUILD_DIR"
    exit 1
fi
