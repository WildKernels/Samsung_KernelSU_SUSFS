#!/bin/bash
################################################################################
# Samsung Galaxy S23 Ultra (S918B) Kernel Build Configuration
# OneUI 8.5 / Android 16 with KernelSU + SUSFS + BBRv3
# Kernel Version: 5.15.178-android13
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build Configuration
export KBUILD_BUILD_VERSION=1
export KBUILD_BUILD_USER="ozon1985"
export KBUILD_BUILD_HOST="kernel-builder"

# Device Configuration
DEVICE_NAME="S918B"
DEVICE_CODENAME="universal9925"
DEVICE_MODEL="SM-S918B"
DEVICE_BRAND="Samsung"
DEVICE_DEVICE="s23ultra"

# Kernel Configuration
KERNEL_VERSION="5.15.178"
ANDROID_VERSION="16"
ONEUI_VERSION="8"
BUILD_NUMBER="$(date +%Y%m%d%H%M%S)"
KERNEL_BUILD_VERSION="${KERNEL_VERSION}-android13-8-${DEVICE_CODENAME}"

# Architecture
TARGET_ARCH="arm64"
TARGET_ARCH_VARIANT="armv9-a"
TARGET_CPU_VARIANT="generic"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_DIR="${SCRIPT_DIR}"
OUT_DIR="${KERNEL_DIR}/out"
CROSS_COMPILE_ARM64="${KERNEL_DIR}/toolchain/aarch64-linux-gnu-"
CLANG_PATH="${KERNEL_DIR}/toolchain/clang"

# Build flags
export ARCH=${TARGET_ARCH}
export CROSS_COMPILE=${CROSS_COMPILE_ARM64}
export CC=${CLANG_PATH}/bin/clang
export CXX=${CLANG_PATH}/bin/clang++
export HOSTCC=${CLANG_PATH}/bin/clang
export HOSTCXX=${CLANG_PATH}/bin/clang++

# Optimization flags
export CFLAGS="-O3 -march=armv9-a -mtune=cortex-a78 -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"

# Kernel build configuration
KERNEL_CONFIG_FILE="${KERNEL_DIR}/arch/arm64/configs/exynos9925_defconfig"
KERNEL_VARIANT_CONFIG="${KERNEL_DIR}/arch/arm64/configs/s23ultra_variant.config"

# Feature flags - KernelSU & SUSFS
ENABLE_KERNELSU=1
ENABLE_SUSFS=1
ENABLE_BBG=1  # Baseband Guard
ENABLE_BBRV3=1
ENABLE_LTO=1  # Link Time Optimization
ENABLE_TMPFS_XATTR=1
ENABLE_DROIDSPACES=1
ENABLE_NTSYNC=1

# Logging function
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Export configuration
export DEVICE_NAME DEVICE_CODENAME DEVICE_MODEL DEVICE_BRAND DEVICE_DEVICE
export KERNEL_VERSION ANDROID_VERSION ONEUI_VERSION BUILD_NUMBER
export TARGET_ARCH TARGET_ARCH_VARIANT TARGET_CPU_VARIANT
export KERNEL_BUILD_VERSION
export ENABLE_KERNELSU ENABLE_SUSFS ENABLE_BBG ENABLE_BBRV3 ENABLE_LTO
export ENABLE_TMPFS_XATTR ENABLE_DROIDSPACES ENABLE_NTSYNC
export log_info log_success log_warning log_error

log_success "Build configuration loaded successfully!"
log_info "Device: ${DEVICE_BRAND} ${DEVICE_MODEL} (${DEVICE_CODENAME})"
log_info "Kernel: ${KERNEL_BUILD_VERSION}"
log_info "Android: ${ANDROID_VERSION} OneUI ${ONEUI_VERSION}"
log_info "Build Number: ${BUILD_NUMBER}"
