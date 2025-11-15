#!/bin/bash
# Monolith Firewall - System Customization Script
# This script runs inside the chroot environment during ISO build

set -e

echo "Customizing Monolith Firewall system..."

# Create monolith user
if ! id -u monolith > /dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo monolith
    echo "monolith:monolith" | chpasswd
    echo "Created monolith user with default password (change after first boot)"
fi

# Set root password
echo "root:monolith" | chpasswd

# Configure sudoers for monolith user
echo "monolith ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/monolith
chmod 0440 /etc/sudoers.d/monolith

# Create directory for Monolith Firewall
mkdir -p /opt/monolith-firewall/{bin,config,logs,data}
chown -R monolith:monolith /opt/monolith-firewall

# Enable IP forwarding (required for firewall/router functionality)
cat >> /etc/sysctl.conf << 'EOF'

# Monolith Firewall - Enable IP forwarding
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

# Disable unnecessary services
systemctl disable bluetooth.service 2>/dev/null || true
systemctl disable cups.service 2>/dev/null || true

# Create MOTD
cat > /etc/motd << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              MONOLITH FIREWALL                            ║
║              Debian 13 (Trixie) Based                     ║
║                                                           ║
║  A powerful, open-source firewall solution                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

Default credentials:
  Username: monolith
  Password: monolith

IMPORTANT: Change the default password immediately!

EOF

# Create systemd service for Monolith Firewall (placeholder)
cat > /etc/systemd/system/monolith-firewall.service << 'EOF'
[Unit]
Description=Monolith Firewall Service
After=network.target

[Service]
Type=simple
User=monolith
WorkingDirectory=/opt/monolith-firewall
ExecStart=/opt/monolith-firewall/bin/MonolithFirewall
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Note: Service is created but not enabled - will be enabled once the binary is deployed

echo "System customization completed!"
