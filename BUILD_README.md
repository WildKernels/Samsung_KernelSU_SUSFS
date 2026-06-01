# Build README for Samsung Galaxy S23 Ultra Kernel

## 🔧 Build System Setup

This directory contains a complete build system for compiling a custom Samsung kernel with KernelSU, SUSFS, and BBRv3 support.

### 📋 Requirements

- **System**: Linux (Ubuntu 20.04 LTS or newer recommended)
- **RAM**: At least 8GB recommended
- **Storage**: 30GB+ free space for toolchain and build artifacts
- **Time**: 30-60 minutes for first build

### 📦 Prerequisites

```bash
# Install build dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    python3 python3-dev \
    git \
    curl wget \
    flex bison \
    libssl-dev libelf-dev \
    bc pahole \
    crossbuild-essential-arm64 \
    crossbuild-essential-armhf \
    device-tree-compiler \
    imagemagick \
    u-boot-tools
```

### 🛠️ Quick Start

#### 1. Clone Repository
```bash
git clone https://github.com/ozon1985/Samsung_KernelSU_SUSFS.git
cd Samsung_KernelSU_SUSFS
git checkout S918B-OneUI8-Android16-BBRv3-Enhanced
```

#### 2. Setup Build Environment
```bash
chmod +x build.sh build_config.sh
source build_config.sh
```

#### 3. Run Build
```bash
./build.sh
```

### 📁 Directory Structure

```
.
├── build.sh                 # Main build script
├── build_config.sh         # Build configuration
├── patches/                # Kernel patches
│   └── 0001-BBRv3-TCP-Congestion-Control.patch
├── kernel_config/          # Kernel configurations
│   └── s23ultra_bbrv3.config
├── out/                    # Build output directory (created)
│   ├── arch/
│   ├── modules_install/
│   ├── build.log
│   └── S918B-OneUI8-*.zip
└── README.md              # This file
```

### ⚙️ Build Configuration

Edit `build_config.sh` to customize:

```bash
# Device settings
DEVICE_NAME="S918B"
DEVICE_MODEL="SM-S918B"

# Kernel version
KERNEL_VERSION="5.15.178"
ANDROID_VERSION="16"
ONEUI_VERSION="8"

# Features (1=enable, 0=disable)
ENABLE_KERNELSU=1
ENABLE_SUSFS=1
ENABLE_BBRV3=1
ENABLE_LTO=1
ENABLE_DROIDSPACES=1
```

### 🚀 Build Process

The build script automatically:
1. ✅ Checks system prerequisites
2. 🔧 Sets up toolchain
3. 📝 Applies kernel patches
4. ⚙️ Configures kernel with BBRv3
5. 🏗️ Compiles kernel image
6. 📦 Builds kernel modules
7. 📦 Creates flashable package
8. 📋 Generates build report

### 📊 Build Output

After successful build:

```
out/
├── arch/arm64/boot/Image.gz          # Kernel image
├── modules_install/                  # Compiled modules
├── S918B-OneUI8-KernelSU-*.zip      # Flashable package
├── BUILD_INFO.txt                    # Build information
├── build.log                         # Detailed build log
└── flashable/                        # Flashable files
```

### 🎯 Features

**Included in this kernel:**

- 🔐 **KernelSU**: Kernel-based root access for Android
- 🥷 **SUSFS**: Root hiding for KernelSU
- 🌐 **BBRv3**: Google's advanced TCP congestion control
  - Better throughput and lower latency
  - Optimized for mobile networks
  - Adaptive bandwidth probing
- 🛡️ **Baseband Guard**: Protects critical device partitions
- ⚡ **LTO**: Link Time Optimization for better performance
- 🖧 **TMPFS XATTR**: Extended attributes support
- 🖥️ **Droidspaces**: Portable Linux container support
- 🔃 **NTSync**: Windows NT synchronization primitives

### 📱 Installation

#### Method 1: ADB (Easiest)
```bash
adb reboot bootloader
# Use Heimdall or Odin to flash kernel partition
adb reboot
```

#### Method 2: Manual Flashing (Advanced)
```bash
# Using Heimdall (Linux)
heimdall flash --KERNEL out/arch/arm64/boot/Image.gz

# Using Odin (Windows)
# Select the Image.gz as kernel in Odin
# Flash to device
```

### ✅ Verification

After installation, verify kernel:

```bash
adb shell uname -r
# Should show: 5.15.178-android13-8-abS918BXXS8EYJ3-Wi

adb shell cat /proc/sys/net/ipv4/tcp_congestion_control
# Should show: bbr (BBRv3)

# Test KernelSU
adb shell su -c "whoami"
# Should show: root
```

### 🐛 Troubleshooting

#### Build fails with missing toolchain
```bash
# Ensure Clang is available
export PATH="/path/to/clang/bin:$PATH"
./build.sh
```

#### Out of memory during build
```bash
# Reduce parallel jobs
make -j4 # Instead of -j$(nproc)
```

#### Kernel won't boot
- Check kernel is correct for S918B
- Ensure all patches applied successfully
- Review build.log for errors
- Try with stock kernel to verify device

#### Module not loading
```bash
# Check module compatibility
adb shell insmod /system/lib/modules/module.ko
# Check dmesg for errors
adb shell dmesg | tail -50
```

### 📚 Documentation

- [KernelSU Documentation](https://kernelsu.org/)
- [SUSFS Repository](https://gitlab.com/simonpunk/susfs4ksu)
- [BBRv3 Details](https://github.com/google/bbr)
- [Samsung Kernel Source](https://opensource.samsung.com/)

### ⚠️ Important Notes

1. **Warranty**: Flashing this kernel will void your device warranty
2. **Backup**: Always backup your data before flashing
3. **Device**: This kernel is for S918B (S23 Ultra) only
4. **Compatibility**: Requires OneUI 8.x / Android 16
5. **Support**: Issues can be reported on GitHub

### 📝 Build Variables

You can override build variables:

```bash
# Custom output directory
OUT_DIR=/tmp/kernel_build ./build.sh

# Specific number of threads
make -j8 O="${OUT_DIR}" ...

# Custom cross compiler
export CROSS_COMPILE=/path/to/arm64-compiler- ./build.sh
```

### 🤝 Contributing

To contribute improvements:

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/improvement`
3. Commit changes: `git commit -am 'Add improvement'`
4. Push to branch: `git push origin feature/improvement`
5. Submit a Pull Request

### 📞 Support & Contact

- 🐛 **Report Issues**: GitHub Issues
- 💬 **Discussion**: GitHub Discussions
- 📱 **Telegram**: [@Ngadhnjim98](https://t.me/Ngadhnjim98)

### 📄 License

This kernel build system is provided under GPL v2 license (as per Linux kernel license).

---

**Last Updated**: June 1, 2026  
**Build System Version**: 1.0  
**Kernel Version**: 5.15.178-android13-8
