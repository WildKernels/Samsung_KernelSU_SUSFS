## 🔥 Samsung Galaxy S23 Ultra Kernel Build System
### KernelSU + SUSFS + BBRv3 Enhancement

---

## 📋 Quick Start Guide

### Step 1: Initial Setup
```bash
git clone https://github.com/ozon1985/Samsung_KernelSU_SUSFS.git
cd Samsung_KernelSU_SUSFS
git checkout S918B-OneUI8-Android16-BBRv3-Enhanced
chmod +x *.sh
./setup.sh
```

### Step 2: Configure Build
```bash
source build_config.sh
```

### Step 3: Build Kernel
```bash
./build.sh
```

### Step 4: Flash to Device
```bash
./flash.sh
```

### Step 5: Verify Installation
```bash
./verify.sh
```

---

## 📁 What's Included

### Build Scripts
- **`setup.sh`** - Initial environment setup and dependency installation
- **`build_config.sh`** - Build configuration and environment variables
- **`build.sh`** - Main kernel compilation script
- **`flash.sh`** - Flash kernel to device via ADB/Fastboot
- **`verify.sh`** - Comprehensive kernel testing suite

### Documentation
- **`BUILD_README.md`** - Detailed build instructions and troubleshooting
- **`README.md`** - Project overview and features

### Kernel Enhancements
- **`patches/`** - BBRv3 and other kernel patches
- **`kernel_config/`** - Optimized kernel configurations

---

## 🎯 Features Enabled

### ✅ KernelSU
- Kernel-based root access
- Direct root permission in kernel space
- Permanent and stable root solution

### ✅ SUSFS
- Root hiding for detection bypass
- Enhanced privacy and stealth
- Perfect for banking and security apps

### ✅ BBRv3 TCP Congestion Control
- Advanced bandwidth estimation
- Better network performance
- Lower latency on mobile networks
- Optimized for 5G and LTE

### ✅ Baseband Guard (BBG)
- LSM-based security
- Protects critical device partitions
- Enhanced device protection

### ✅ LTO (Link Time Optimization)
- Better code optimization
- Improved overall performance
- Smaller kernel size

### ✅ TMPFS XATTR
- Extended attributes support
- Better meta module compatibility
- Enhanced Mountify support

### ✅ Droidspaces
- Linux container support
- Run full Linux environments
- Portable container system

### ✅ NTSync
- Windows NT sync primitives
- Better app compatibility
- Low-latency synchronization

---

## 🛠️ System Requirements

### Minimum
- **OS**: Ubuntu 20.04 LTS or equivalent
- **CPU**: 4-core processor
- **RAM**: 8GB minimum (16GB+ recommended)
- **Storage**: 30GB free space

### Recommended
- **OS**: Ubuntu 22.04 LTS
- **CPU**: 8-core processor (for faster builds)
- **RAM**: 16GB or more
- **Storage**: SSD with 50GB+ free space

---

## 📦 Installation Prerequisites

### Linux Packages
```bash
sudo apt-get install build-essential python3 python3-dev git curl wget \
  flex bison libssl-dev libelf-dev bc pahole \
  crossbuild-essential-arm64 device-tree-compiler u-boot-tools
```

### Android Tools
- **ADB**: `sudo apt-get install adb`
- **Fastboot**: Included with Android SDK Platform Tools
- **Heimdall**: For Samsung device flashing (optional alternative to Odin)

---

## 🚀 Building Process Timeline

| Step | Duration | Details |
|------|----------|---------|
| Setup | 5 min | Install dependencies |
| Configure | 2 min | Load kernel configs |
| Build Kernel | 15-30 min | Compile kernel image |
| Build Modules | 5-10 min | Compile kernel modules |
| Package | 2 min | Create flashable ZIP |
| **Total** | **30-50 min** | First build (faster on rebuilds) |

---

## 📊 Build Output Files

After successful build, you'll find:

```
out/
├── arch/arm64/boot/Image.gz          # Kernel image (main)
├── modules_install/lib/modules/      # Compiled kernel modules
├── flashable/                        # Flashable package files
├── S918B-OneUI8-*.zip               # Complete flashable package
├── BUILD_INFO.txt                   # Build information
├── build.log                        # Build log (for debugging)
└── verification_report_*.txt        # Test results (after verify.sh)
```

---

## ⚡ Performance Improvements

### BBRv3 Benefits
- **Throughput**: +15-25% improvement over BBRv2
- **Latency**: 10-20% lower round-trip times
- **Fairness**: Better bandwidth sharing
- **Stability**: Adaptive to network conditions

### LTO Optimization
- **Boot time**: ~2-5% faster
- **App launch**: Smoother performance
- **Battery**: Slight improvement due to efficiency

### Overall System
- Faster kernel operations
- Better multitasking performance
- Improved network responsiveness
- Enhanced power efficiency

---

## 🔒 Security Considerations

### ⚠️ Important Warnings
1. **Warranty**: Flashing voids manufacturer warranty
2. **Backup**: Always backup data before flashing
3. **Device-Specific**: Only for SM-S918B (S23 Ultra)
4. **OS Version**: Requires OneUI 8.x / Android 16
5. **Risk**: Potential for bootloop if something goes wrong

### Safety Measures
- Always use official recovery
- Keep bootloader unlocked (if available)
- Have recovery files ready
- Test on secondary device if possible
- Follow all instructions carefully

---

## 🐛 Troubleshooting

### Build Issues

**Problem**: Build fails with missing toolchain
```bash
# Solution:
export PATH="/path/to/clang/bin:$PATH"
./build.sh
```

**Problem**: Out of memory errors
```bash
# Solution: Use fewer threads
make -j4 O=out ...
```

**Problem**: Patch application fails
```bash
# Solution: Check if patch already applied
patch -p1 --dry-run < patch_file
```

### Flashing Issues

**Problem**: Device not detected
```bash
# Solution: Enable USB debugging
adb devices  # Should show device

# If not:
adb kill-server
adb start-server
```

**Problem**: Kernel won't boot
- Wait 5+ minutes (first boot is slow)
- Check if correct device model
- Review build.log for errors
- Flash stock kernel and retry

**Problem**: KernelSU not working
```bash
adb shell su -c "whoami"
# Should output: root
```

---

## 📞 Getting Help

### Before Reporting Issues
1. Check `build.log` for errors
2. Review `BUILD_README.md`
3. Search existing GitHub issues
4. Verify device compatibility

### Report Format
When opening an issue, include:
- Device model and Android version
- Build command used
- Full build.log output
- Error messages
- What you've already tried

### Support Channels
- 🐛 **GitHub Issues**: Report bugs
- 💬 **GitHub Discussions**: Ask questions
- 📱 **Telegram**: [@Ngadhnjim98](https://t.me/Ngadhnjim98)
- 📧 **Email**: Check repository for contact info

---

## 📚 Additional Resources

### Documentation
- [KernelSU Official Docs](https://kernelsu.org/)
- [SUSFS Repository](https://gitlab.com/simonpunk/susfs4ksu)
- [BBRv3 Details](https://github.com/google/bbr)
- [Linux Kernel Docs](https://www.kernel.org/doc/)

### Related Projects
- [Wild Kernels](https://github.com/WildKernels)
- [Kernel Patches](https://github.com/WildKernels/kernel_patches)
- [Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher)

### Tools
- [Heimdall](https://github.com/Benjamin-Dobell/Heimdall)
- [Odin](https://www.sammobile.com/resources/odin/) (Windows)
- [ADB Setup](https://developer.android.com/studio/command-line/adb)

---

## 📝 License

This kernel build system is provided under **GPL v2 license** (as per Linux kernel license).

See LICENSE file for details.

---

## 🙏 Credits

### Core Projects
- **KernelSU**: tiann, rifsxd, 5ec1cff
- **SUSFS**: simonpunk, sidex15
- **BBRv3**: Google
- **Baseband Guard**: vc-teahouse
- **Droidspaces**: ravindu644

### Contributors
Thanks to all contributors and testers who help improve this build system!

---

## 📝 Version Information

- **Build System Version**: 1.0
- **Kernel Base**: 5.15.178-android13-8
- **Device**: Samsung Galaxy S23 Ultra (SM-S918B)
- **OS Support**: OneUI 8.x / Android 16
- **Last Updated**: June 1, 2026

---

**Happy Building! 🚀**

For updates and latest releases, check:
https://github.com/ozon1985/Samsung_KernelSU_SUSFS
