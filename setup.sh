#!/bin/bash
################################################################################
# Initial Setup Script - Samsung S23 Ultra Kernel Build
# Run this first to prepare your build environment
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
info() { echo -e "${BLUE}[ℹ]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# Header
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║    Samsung Galaxy S23 Ultra Kernel Build Setup            ║"
echo "║    KernelSU + SUSFS + BBRv3 Enhancement                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check OS
info "Checking operating system..."
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    error "This script only works on Linux. Please use a Linux system."
    exit 1
fi
success "Linux system detected"

# Check for package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    success "Using apt-get package manager"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    success "Using yum package manager"
else
    error "Unsupported package manager"
    exit 1
fi

# Install dependencies
info ""
info "Installing system dependencies..."

sudo $PKG_MANAGER update -y

PACKAGES=(
    "build-essential"
    "python3"
    "python3-dev"
    "git"
    "curl"
    "wget"
    "flex"
    "bison"
    "libssl-dev"
    "libelf-dev"
    "bc"
    "pahole"
    "crossbuild-essential-arm64"
    "device-tree-compiler"
    "u-boot-tools"
)

for pkg in "${PACKAGES[@]}"; do
    if sudo $PKG_MANAGER install -y "$pkg" > /dev/null 2>&1; then
        success "Installed: $pkg"
    else
        warning "Could not install: $pkg (may already be installed)"
    fi
done

# Set permissions
info ""
info "Setting up script permissions..."

chmod +x build.sh build_config.sh flash.sh verify.sh setup.sh 2>/dev/null || true
success "Script permissions set"

# Verify toolchain
info ""
info "Verifying toolchain availability..."

if command -v aarch64-linux-gnu-gcc &> /dev/null; then
    success "ARM64 cross-compiler found"
else
    warning "ARM64 cross-compiler not in PATH"
fi

if command -v adb &> /dev/null; then
    success "ADB found"
else
    warning "ADB not found (needed for flashing)"
    info "Install from: https://developer.android.com/studio/releases/platform-tools"
fi

# Create output directory
info ""
info "Creating build directories..."

mkdir -p out/
mkdir -p patches/
mkdir -p kernel_config/

success "Build directories created"

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║             Setup Complete! Ready to Build                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "Next steps:"
echo ""
echo "  1. Load build configuration:"
echo "     ${BLUE}source build_config.sh${NC}"
echo ""
echo "  2. Start the build:"
echo "     ${BLUE}./build.sh${NC}"
echo ""
echo "  3. After build completes, flash to device:"
echo "     ${BLUE}./flash.sh${NC}"
echo ""
echo "  4. Verify installation on device:"
echo "     ${BLUE}./verify.sh${NC}"
echo ""

echo "For detailed instructions, see:"
echo "  ${BLUE}BUILD_README.md${NC}"
echo ""

echo "📚 Documentation:"
echo "  - Build System: BUILD_README.md"
echo "  - Configuration: build_config.sh"
echo "  - Building: ./build.sh"
echo "  - Flashing: ./flash.sh"
echo "  - Testing: ./verify.sh"
echo ""

success "Setup completed successfully!"
echo ""
