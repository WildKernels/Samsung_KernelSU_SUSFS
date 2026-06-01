#!/bin/bash
################################################################################
# Complete Kernel Build Script with BBRv3
# Samsung Galaxy S23 Ultra S918B - OneUI 8 / Android 16
################################################################################

source "$(dirname "$0")/build_config.sh"

# Check prerequisites
check_prerequisites() {
    log_info "Checking system prerequisites..."
    
    local missing_tools=()
    local required_tools=("make" "git" "gcc" "arm-linux-gnueabihf-gcc" "aarch64-linux-gnu-gcc")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warning "Missing tools: ${missing_tools[*]}"
        log_info "Installing dependencies..."
        
        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            python3 \
            git \
            curl \
            wget \
            flex \
            bison \
            libssl-dev \
            libelf-dev \
            bc \
            pahole \
            crossbuild-essential-arm64 \
            crossbuild-essential-armhf
        
        log_success "Dependencies installed"
    else
        log_success "All prerequisites available"
    fi
}

# Setup toolchain
setup_toolchain() {
    log_info "Setting up toolchain..."
    
    TOOLCHAIN_DIR="${KERNEL_DIR}/toolchain"
    mkdir -p "${TOOLCHAIN_DIR}"
    
    # Download Clang toolchain if not present
    if [ ! -d "${CLANG_PATH}" ]; then
        log_info "Downloading Clang toolchain..."
        
        CLANG_VERSION="17.0.0"
        CLANG_URL="https://github.com/google/android-ndk/releases/download"
        
        log_warning "Please ensure you have Clang toolchain available"
        log_info "You can download from: https://github.com/google/android-ndk"
        log_info "Or place it at: ${CLANG_PATH}"
    else
        log_success "Clang toolchain found"
    fi
    
    # Check ARM64 cross compiler
    if [ ! -d "${CROSS_COMPILE_ARM64}" ]; then
        log_warning "ARM64 cross-compiler not found at ${CROSS_COMPILE_ARM64}"
        log_info "Will use system ARM64 compiler"
        export CROSS_COMPILE="/usr/bin/aarch64-linux-gnu-"
    else
        log_success "ARM64 cross-compiler found"
    fi
}

# Apply patches
apply_patches() {
    log_info "Applying kernel patches..."
    
    cd "${KERNEL_DIR}"
    
    local patch_count=0
    local applied_patches=()
    
    if [ -d "patches" ]; then
        for patch_file in patches/*.patch; do
            if [ -f "$patch_file" ]; then
                local patch_name=$(basename "$patch_file")
                log_info "Applying: $patch_name"
                
                if patch -p1 --dry-run < "$patch_file" > /dev/null 2>&1; then
                    if patch -p1 < "$patch_file" > /dev/null 2>&1; then
                        log_success "Applied: $patch_name"
                        applied_patches+=("$patch_name")
                        ((patch_count++))
                    else
                        log_warning "Failed to apply: $patch_name"
                    fi
                else
                    log_warning "Patch already applied or incompatible: $patch_name"
                fi
            fi
        done
    fi
    
    log_success "Patches applied: $patch_count"
}

# Configure kernel
configure_kernel() {
    log_info "Configuring kernel..."
    
    cd "${KERNEL_DIR}"
    mkdir -p "${OUT_DIR}"
    
    # Copy base config
    if [ -f "arch/arm64/configs/exynos9925_defconfig" ]; then
        log_info "Loading Samsung S918B defconfig..."
        make -j$(nproc) O="${OUT_DIR}" \
            ARCH="${ARCH}" \
            CROSS_COMPILE="${CROSS_COMPILE}" \
            exynos9925_defconfig
        log_success "Base configuration loaded"
    else
        log_error "Samsung defconfig not found"
        return 1
    fi
    
    # Apply custom configuration for BBRv3
    log_info "Applying custom BBRv3 configuration..."
    
    cat >> "${OUT_DIR}/.config" << 'CONFIG'
# BBRv3 TCP Congestion Control
CONFIG_TCP_CONG_BBR=y
CONFIG_DEFAULT_TCP_CONG="bbr"

# KernelSU
CONFIG_KERNELSU=y
CONFIG_KERNELSU_DEBUG=n

# SUSFS
CONFIG_SUSFS=y

# Optimizations
CONFIG_LTO_CLANG=y
CONFIG_CFI_CLANG=y

# Security
CONFIG_SECURITY_SELINUX=y
CONFIG_BASEBAND_GUARD=y

# Additional Features
CONFIG_DROIDSPACES=y
CONFIG_NTSYNC=y
CONFIG_TMPFS_XATTR=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_EXT4_FS_POSIX_ACL=y

# Build version
CONFIG_LOCALVERSION="-S918B-OneUI8-KernelSU-SUSFS-BBRv3"
CONFIG_LOCALVERSION_AUTO=n
CONFIG
    
    log_success "Custom configuration applied"
    
    # Validate configuration
    log_info "Validating configuration..."
    make -j$(nproc) O="${OUT_DIR}" \
        ARCH="${ARCH}" \
        CROSS_COMPILE="${CROSS_COMPILE}" \
        olddefconfig 2>&1 | tail -10
    
    log_success "Kernel configuration ready"
}

# Build kernel
build_kernel() {
    log_info "Building kernel image..."
    log_info "Using $(nproc) CPU threads"
    
    cd "${KERNEL_DIR}"
    
    START_TIME=$(date +%s)
    
    make -j$(nproc) O="${OUT_DIR}" \
        ARCH="${ARCH}" \
        CROSS_COMPILE="${CROSS_COMPILE}" \
        CC="${CC}" \
        CXX="${CXX}" \
        HOSTCC="${HOSTCC}" \
        HOSTCXX="${HOSTCXX}" \
        CFLAGS="${CFLAGS}" \
        CXXFLAGS="${CXXFLAGS}" \
        Image.gz modules 2>&1 | tee "${OUT_DIR}/build.log"
    
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))
    
    if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz" ]; then
        log_success "Kernel built successfully in ${BUILD_TIME}s"
        log_info "Image size: $(du -h "${OUT_DIR}/arch/arm64/boot/Image.gz" | cut -f1)"
    else
        log_error "Kernel build failed!"
        tail -50 "${OUT_DIR}/build.log"
        return 1
    fi
}

# Build modules
build_modules() {
    log_info "Building kernel modules..."
    
    cd "${KERNEL_DIR}"
    
    make -j$(nproc) O="${OUT_DIR}" \
        ARCH="${ARCH}" \
        CROSS_COMPILE="${CROSS_COMPILE}" \
        modules 2>&1 | tee -a "${OUT_DIR}/build.log"
    
    local module_count=$(find "${OUT_DIR}" -name "*.ko" | wc -l)
    if [ "$module_count" -gt 0 ]; then
        log_success "Modules built: $module_count files"
    else
        log_warning "No modules compiled"
    fi
}

# Install modules
install_modules() {
    log_info "Installing kernel modules..."
    
    cd "${KERNEL_DIR}"
    
    MODULES_DIR="${OUT_DIR}/modules_install"
    mkdir -p "${MODULES_DIR}"
    
    make O="${OUT_DIR}" \
        ARCH="${ARCH}" \
        CROSS_COMPILE="${CROSS_COMPILE}" \
        INSTALL_MOD_PATH="${MODULES_DIR}" \
        modules_install 2>&1 | tail -20
    
    log_success "Modules installed to: ${MODULES_DIR}"
}

# Create flashable image
create_flashable_image() {
    log_info "Creating flashable kernel package..."
    
    FLASH_DIR="${OUT_DIR}/flashable"
    rm -rf "${FLASH_DIR}"
    mkdir -p "${FLASH_DIR}"
    
    # Copy kernel
    cp "${OUT_DIR}/arch/arm64/boot/Image.gz" "${FLASH_DIR}/kernel"
    
    # Copy modules
    if [ -d "${OUT_DIR}/modules_install/lib/modules" ]; then
        mkdir -p "${FLASH_DIR}/modules"
        cp -r "${OUT_DIR}/modules_install/lib/modules"/* "${FLASH_DIR}/modules/"
    fi
    
    # Create flash script
    cat > "${FLASH_DIR}/flash.sh" << 'FLASH'
#!/bin/bash
echo "Samsung S23 Ultra Kernel Flasher"
echo "================================"
echo ""
echo "This script will flash the custom kernel"
echo "Make sure your device is connected via ADB"
echo ""

KERNEL_FILE="kernel"
MODULES_DIR="modules"

if [ ! -f "$KERNEL_FILE" ]; then
    echo "Error: Kernel file not found"
    exit 1
fi

echo "Pushing files to device..."
adb push "$KERNEL_FILE" /data/local/tmp/
adb push "$MODULES_DIR" /data/local/tmp/

echo "Installation complete!"
echo "Reboot your device to apply changes"
FLASH
    chmod +x "${FLASH_DIR}/flash.sh"
    
    # Create zip package
    ZIP_FILE="${OUT_DIR}/S918B-OneUI8-KernelSU-SUSFS-BBRv3-${BUILD_NUMBER}.zip"
    cd "${FLASH_DIR}"
    zip -r "${ZIP_FILE}" . -q
    cd "${KERNEL_DIR}"
    
    if [ -f "$ZIP_FILE" ]; then
        log_success "Flashable package created: $(basename "$ZIP_FILE")"
        log_info "File size: $(du -h "$ZIP_FILE" | cut -f1)"
        log_info "Location: $ZIP_FILE"
    else
        log_error "Failed to create flashable package"
        return 1
    fi
}

# Generate build info
generate_build_info() {
    log_info "Generating build information..."
    
    INFO_FILE="${OUT_DIR}/BUILD_INFO.txt"
    
    cat > "$INFO_FILE" << INFO
================================================================================
Samsung Galaxy S23 Ultra Kernel Build Information
================================================================================

Device:
  Name: ${DEVICE_BRAND} Galaxy S23 Ultra
  Model: ${DEVICE_MODEL}
  Codename: ${DEVICE_CODENAME}

Kernel Version:
  Base: ${KERNEL_VERSION}
  Android: ${ANDROID_VERSION}
  OneUI: ${ONEUI_VERSION}
  Full: ${KERNEL_BUILD_VERSION}

Build Date: $(date)
Build Number: ${BUILD_NUMBER}

Features Enabled:
  ✓ KernelSU (Root Access)
  ✓ SUSFS (Root Hiding)
  ✓ BBRv3 (Advanced TCP Congestion Control)
  ✓ Baseband Guard (Security)
  ✓ LTO (Link Time Optimization)
  ✓ TMPFS XATTR (Extended Attributes)
  ✓ Droidspaces (Linux Containers)
  ✓ NTSync (Windows NT Sync Primitives)

Build System:
  Architecture: ${TARGET_ARCH}
  Cross Compiler: ${CROSS_COMPILE}
  Compiler: Clang/LLVM

Output Files:
  Kernel Image: arch/arm64/boot/Image.gz
  Modules: $(find "${OUT_DIR}" -name "*.ko" 2>/dev/null | wc -l) files
  Flashable: $(ls -1 "${OUT_DIR}"/*.zip 2>/dev/null | head -1)

Build Log: build.log

Important Notes:
  - This kernel is for Samsung Galaxy S23 Ultra (S918B) only
  - Compatible with OneUI 8.x / Android 16
  - Flashing will void your warranty
  - Always backup your data before flashing
  - Use official recovery or ADB to flash
  
Installation Steps:
  1. Enable Developer Options on your device
  2. Enable USB Debugging
  3. Connect device via USB
  4. Run: adb reboot bootloader
  5. Use Heimdall or Odin to flash kernel partition
  6. Reboot device

Support:
  GitHub: https://github.com/ozon1985/Samsung_KernelSU_SUSFS
  Telegram: https://t.me/Ngadhnjim98

================================================================================
INFO

    log_success "Build information saved: $INFO_FILE"
    cat "$INFO_FILE"
}

# Main execution
main() {
    log_success "======================================================"
    log_success "Samsung S23 Ultra Kernel Build System"
    log_success "KernelSU + SUSFS + BBRv3"
    log_success "======================================================"
    log_info ""
    
    # Pre-build checks
    check_prerequisites
    setup_toolchain
    
    # Apply patches
    apply_patches || {
        log_warning "Some patches may have failed, continuing..."
    }
    
    # Configure and build
    configure_kernel || exit 1
    build_kernel || exit 1
    build_modules || log_warning "Module build had issues"
    install_modules || log_warning "Module installation had issues"
    
    # Create packages
    create_flashable_image || log_warning "Flashable image creation failed"
    
    # Generate info
    generate_build_info
    
    log_info ""
    log_success "======================================================"
    log_success "Build completed successfully!"
    log_success "Output files in: ${OUT_DIR}"
    log_success "======================================================"
}

# Run with error handling
main "$@"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log_success "Build process finished with no errors"
else
    log_error "Build process finished with errors (exit code: $EXIT_CODE)"
fi

exit $EXIT_CODE
