#!/bin/bash
################################################################################
# Kernel Flash Helper Script
# Flashes the compiled kernel to Samsung S23 Ultra device
################################################################################

set -e

source "$(dirname "$0")/build_config.sh"

# Check if device is connected
check_device() {
    log_info "Checking for connected device..."
    
    if ! command -v adb &> /dev/null; then
        log_error "ADB not found. Please install Android SDK Platform Tools"
        exit 1
    fi
    
    local devices=$(adb devices | grep -c "device$" || true)
    
    if [ "$devices" -eq 0 ]; then
        log_error "No Android device detected"
        log_info "Please connect your device and enable USB debugging"
        exit 1
    fi
    
    log_success "Device detected"
}

# Get device info
get_device_info() {
    log_info "Getting device information..."
    
    DEVICE_MODEL=$(adb shell getprop ro.boot.hardware)
    DEVICE_ANDROID=$(adb shell getprop ro.build.version.release)
    DEVICE_KERNEL=$(adb shell uname -r)
    
    log_info "Device Model: $DEVICE_MODEL"
    log_info "Android Version: $DEVICE_ANDROID"
    log_info "Kernel: $DEVICE_KERNEL"
    
    if [[ "$DEVICE_MODEL" != "universal9925" ]]; then
        log_error "This kernel is only for S918B (universal9925)"
        log_error "Your device: $DEVICE_MODEL"
        exit 1
    fi
}

# Push files to device
push_files() {
    log_info "Pushing kernel to device..."
    
    KERNEL_FILE="${OUT_DIR}/arch/arm64/boot/Image.gz"
    
    if [ ! -f "$KERNEL_FILE" ]; then
        log_error "Kernel file not found: $KERNEL_FILE"
        log_info "Please build the kernel first using: ./build.sh"
        exit 1
    fi
    
    adb push "$KERNEL_FILE" /data/local/tmp/kernel_new
    log_success "Kernel pushed to device"
    
    # Push modules if available
    if [ -d "${OUT_DIR}/modules_install/lib/modules" ]; then
        log_info "Pushing modules..."
        adb push "${OUT_DIR}/modules_install/lib/modules"/* /data/local/tmp/modules/
        log_success "Modules pushed"
    fi
}

# Reboot to bootloader
reboot_bootloader() {
    log_info "Rebooting to bootloader..."
    log_warning "Device will reboot. Do not disconnect!"
    
    sleep 2
    adb reboot bootloader
    
    log_info "Waiting for device in bootloader mode..."
    sleep 5
    
    # Check if device is in bootloader
    if command -v fastboot &> /dev/null; then
        if fastboot devices | grep -q "fastboot"; then
            log_success "Device is in fastboot mode"
        else
            log_warning "Device not detected in fastboot mode"
        fi
    fi
}

# Flash kernel
flash_kernel() {
    log_info "Flashing kernel..."
    
    if ! command -v heimdall &> /dev/null && ! command -v fastboot &> /dev/null; then
        log_error "Neither heimdall nor fastboot found"
        log_info "Please install one of:"
        log_info "  - Heimdall: https://github.com/Benjamin-Dobell/Heimdall"
        log_info "  - Android SDK Platform Tools (fastboot)"
        exit 1
    fi
    
    KERNEL_FILE="${OUT_DIR}/arch/arm64/boot/Image.gz"
    
    if command -v heimdall &> /dev/null; then
        log_info "Using Heimdall to flash..."
        heimdall flash --KERNEL "$KERNEL_FILE"
    elif command -v fastboot &> /dev/null; then
        log_info "Using Fastboot to flash..."
        fastboot flash kernel "$KERNEL_FILE"
    fi
    
    log_success "Kernel flashed successfully"
}

# Reboot device
reboot_device() {
    log_info "Rebooting device..."
    
    if command -v fastboot &> /dev/null; then
        fastboot reboot
    elif command -v adb &> /dev/null; then
        adb reboot
    fi
    
    log_info "Device is rebooting. This may take a few minutes..."
    sleep 30
    
    # Wait for device to come back online
    local max_attempts=30
    local attempts=0
    
    while [ $attempts -lt $max_attempts ]; do
        if adb devices | grep -q "device$"; then
            log_success "Device is back online!"
            return 0
        fi
        
        ((attempts++))
        sleep 2
    done
    
    log_warning "Device did not come back online in time"
    log_info "Please wait a bit longer or check your device manually"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Give device time to settle
    sleep 5
    
    # Check if device is reachable
    if ! adb devices | grep -q "device$"; then
        log_warning "Device not reachable for verification"
        return 1
    fi
    
    # Check kernel version
    local kernel_version=$(adb shell uname -r 2>/dev/null || echo "unknown")
    log_info "Device kernel: $kernel_version"
    
    if [[ "$kernel_version" == *"S918B"* ]]; then
        log_success "Kernel verification passed!"
        
        # Check BBRv3
        local bbr_status=$(adb shell cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || echo "unknown")
        log_info "TCP Congestion Control: $bbr_status"
        
        # Check KernelSU
        if adb shell command -v su &> /dev/null; then
            log_success "KernelSU is available"
        else
            log_warning "KernelSU status unknown"
        fi
        
        return 0
    else
        log_warning "Could not verify kernel installation"
        return 1
    fi
}

# Main function
main() {
    log_success "======================================================"
    log_success "Samsung S23 Ultra Kernel Flash Tool"
    log_success "======================================================"
    log_info ""
    
    # Pre-flight checks
    check_device
    get_device_info
    
    # Confirm action
    log_warning ""
    log_warning "IMPORTANT: This will flash a custom kernel to your device"
    log_warning "Make sure you have:"
    log_warning "  - Backup of your device data"
    log_warning "  - USB cable connected"
    log_warning "  - Device battery > 50%"
    log_warning "  - USB debugging enabled"
    log_warning ""
    
    read -p "Continue with kernel flashing? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "Flash cancelled"
        exit 0
    fi
    
    # Push files
    push_files
    
    # Reboot and flash
    reboot_bootloader
    flash_kernel
    reboot_device
    
    # Verify
    verify_installation
    
    log_info ""
    log_success "======================================================"
    log_success "Flash process completed!"
    log_success "======================================================"
    log_info ""
    log_info "If kernel doesn't boot:"
    log_info "  1. Wait 5 minutes before assuming failure"
    log_info "  2. Use recovery to restore backup if needed"
    log_info "  3. Check GitHub issues for solutions"
    log_info ""
}

# Run main
main "$@"
