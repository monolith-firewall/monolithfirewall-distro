# Monolith Firewall - Build Guide

## Project Structure

```
monolithfirewall-distro/
├── src/                          # C# source code
│   └── MonolithFirewall/         # Main firewall application
│       ├── Core/                 # Core firewall logic
│       ├── UI/                   # User interface components
│       ├── Services/             # Background services
│       ├── Config/               # Configuration management
│       ├── Utils/                # Utility functions
│       ├── MonolithFirewall.csproj
│       └── Program.cs
│
├── build/                        # Build artifacts
│   ├── bin/                      # Compiled binaries
│   ├── obj/                      # Intermediate objects
│   └── release/                  # Release builds
│
├── distro/                       # Debian 13 ISO builder
│   ├── build-iso.sh              # Main ISO builder script
│   ├── config/                   # Build configurations
│   │   ├── build.conf
│   │   └── packages.list
│   ├── scripts/                  # Helper scripts
│   │   └── deploy-firewall.sh
│   ├── chroot-scripts/           # Chroot customization
│   │   └── 01-customize-system.sh
│   ├── packages/                 # Custom .deb packages
│   └── iso-output/               # Final ISO files
│
├── README.md                     # Project overview
├── BUILD.md                      # This file
└── LICENSE                       # Non-Commercial MIT License
```

## Building the C# Application

### Prerequisites

- .NET 8.0 SDK
- Linux, macOS, or Windows

### Build Steps

1. Navigate to the source directory:
   ```bash
   cd src/MonolithFirewall
   ```

2. Restore dependencies:
   ```bash
   dotnet restore
   ```

3. Build the project:
   ```bash
   dotnet build -c Release
   ```

4. Publish for Linux (x64):
   ```bash
   dotnet publish -c Release -r linux-x64 --self-contained false -o ../../build/release
   ```

## Building the Debian ISO

### Prerequisites

- Debian-based Linux system (Debian 11+, Ubuntu 20.04+)
- Root access
- 8-10 GB free disk space
- Internet connection

### Build Steps

1. Navigate to the distro directory:
   ```bash
   cd distro
   ```

2. Run the ISO builder (as root):
   ```bash
   sudo ./build-iso.sh
   ```

3. Wait for the build to complete (15-30 minutes)

4. Find the ISO in `iso-output/`:
   ```bash
   ls -lh iso-output/
   ```

## Complete Build Workflow

To build everything from scratch:

```bash
# 1. Build the C# application
cd src/MonolithFirewall
dotnet publish -c Release -r linux-x64 --self-contained false -o ../../build/release
cd ../..

# 2. Build the Debian ISO
cd distro
sudo ./build-iso.sh
```

## Testing the ISO

### Using QEMU

```bash
qemu-system-x86_64 \
    -cdrom distro/iso-output/monolith-firewall-*.iso \
    -m 2048 \
    -enable-kvm \
    -boot d
```

### Writing to USB

```bash
sudo dd if=distro/iso-output/monolith-firewall-*.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

Replace `/dev/sdX` with your USB device (check with `lsblk`).

## Development Workflow

1. **Modify Source Code**: Edit files in `src/MonolithFirewall/`
2. **Build**: Run `dotnet build` to test your changes
3. **Publish**: Run `dotnet publish` to create release binaries
4. **Create ISO**: Run `build-iso.sh` to build a bootable ISO with your changes

## Customizing the ISO

### Adding Packages

Edit `distro/config/packages.list` to add more packages to the ISO.

### Custom Configuration

Modify `distro/chroot-scripts/01-customize-system.sh` to customize the system configuration.

### Boot Menu

Edit the ISOLINUX and GRUB configurations in `distro/build-iso.sh`.

## Troubleshooting

### Build fails with permission errors

Make sure you're running the ISO builder as root:
```bash
sudo ./build-iso.sh
```

### Missing dependencies

The build script will automatically install required dependencies, but ensure your package lists are updated:
```bash
sudo apt-get update
```

### Out of disk space

The build requires ~8-10 GB. Check available space:
```bash
df -h
```

## Clean Build

To start fresh:

```bash
# Clean C# build
cd src/MonolithFirewall
dotnet clean
cd ../..
rm -rf build/bin/* build/obj/* build/release/*

# Clean ISO build
cd distro
sudo rm -rf work iso-output/*.iso iso-output/*.sha256 iso-output/*.md5
```
