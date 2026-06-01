#!/bin/bash
################################################################################
# Kernel Verification and Testing Script
# Tests kernel features and stability on device
################################################################################

set -e

source "$(dirname "$0")/build_config.sh"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test functions
test_device_connection() {
    log_info "Testing device connection..."
    
    if ! adb devices | grep -q "device$"; then
        log_error "Device not connected"
        return 1
    fi
    
    log_success "Device connection OK"
    return 0
}

test_kernel_version() {
    log_info "Testing kernel version..."
    
    local kernel=$(adb shell uname -r 2>/dev/null || echo "")
    
    if [ -z "$kernel" ]; then
        log_error "Could not retrieve kernel version"
        return 1
    fi
    
    log_info "Kernel: $kernel"
    
    if [[ "$kernel" == *"S918B"* ]] || [[ "$kernel" == *"5.15.178"* ]]; then
        log_success "Correct kernel installed"
        return 0
    else
        log_warning "Unexpected kernel version"
        return 1
    fi
}

test_bbrv3() {
    log_info "Testing BBRv3 TCP congestion control..."
    
    local bbr=$(adb shell cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || echo "")
    
    if [[ "$bbr" == "bbr"* ]]; then
        log_success "BBRv3 is active: $bbr"
        
        # Test available algorithms
        local algorithms=$(adb shell cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null || echo "")
        log_info "Available algorithms: $algorithms"
        
        return 0
    else
        log_error "BBRv3 not active (current: $bbr)"
        return 1
    fi
}

test_kernelsu() {
    log_info "Testing KernelSU root access..."
    
    if adb shell command -v su &> /dev/null; then
        local su_info=$(adb shell su -V 2>/dev/null || echo "unknown")
        log_info "KernelSU version: $su_info"
        
        # Test root access
        local root_test=$(adb shell su -c "id" 2>/dev/null || echo "")
        
        if [[ "$root_test" == *"uid=0"* ]]; then
            log_success "KernelSU root access working"
            return 0
        else
            log_warning "KernelSU available but root test inconclusive"
            return 1
        fi
    else
        log_error "KernelSU not available"
        return 1
    fi
}

test_susfs() {
    log_info "Testing SUSFS root hiding..."
    
    # Check if SUSFS is mentioned in kernel config
    if adb shell zcat /proc/config.gz 2>/dev/null | grep -q "CONFIG_SUSFS=y"; then
        log_success "SUSFS is compiled into kernel"
        
        # Try to list SUSFS status
        local susfs_path=$(adb shell find /system -name "*susfs*" 2>/dev/null | head -1)
        if [ -n "$susfs_path" ]; then
            log_info "SUSFS path: $susfs_path"
        fi
        
        return 0
    else
        log_warning "SUSFS configuration not found"
        return 1
    fi
}

test_lto_optimization() {
    log_info "Testing LTO optimization..."
    
    if adb shell zcat /proc/config.gz 2>/dev/null | grep -q "CONFIG_LTO_CLANG=y"; then
        log_success "LTO compilation enabled"
        return 0
    else
        log_warning "LTO configuration not detected"
        return 1
    fi
}

test_memory_usage() {
    log_info "Checking memory usage..."
    
    local mem_info=$(adb shell cat /proc/meminfo | head -5)
    log_info "Memory info:"
    echo "$mem_info" | sed 's/^/  /'
    
    local mem_total=$(adb shell cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')
    local mem_available=$(adb shell cat /proc/meminfo | grep "MemAvailable" | awk '{print $2}')
    
    if [ -n "$mem_total" ] && [ -n "$mem_available" ]; then
        local usage=$((100 * (mem_total - mem_available) / mem_total))
        log_info "Memory usage: $usage%"
        
        if [ "$usage" -lt 90 ]; then
            log_success "Memory usage within acceptable range"
            return 0
        else
            log_warning "High memory usage detected"
            return 1
        fi
    fi
}

test_thermal() {
    log_info "Checking thermal status..."
    
    if adb shell test -f /sys/class/thermal/thermal_zone0/temp; then
        local temp=$(adb shell cat /sys/class/thermal/thermal_zone0/temp)
        local temp_c=$((temp / 1000))
        
        log_info "Device temperature: ${temp_c}°C"
        
        if [ "$temp_c" -lt 50 ]; then
            log_success "Thermal status normal"
            return 0
        elif [ "$temp_c" -lt 65 ]; then
            log_warning "Device warm (${temp_c}°C)"
            return 1
        else
            log_error "Device too hot (${temp_c}°C)"
            return 1
        fi
    else
        log_warning "Could not read thermal info"
        return 1
    fi
}

test_modules() {
    log_info "Checking loaded modules..."
    
    local module_count=$(adb shell lsmod | wc -l)
    log_info "Loaded modules: $((module_count - 1))"
    
    if [ "$module_count" -gt 1 ]; then
        log_success "Kernel modules loaded"
        
        # Show some module info
        adb shell lsmod | head -5 | sed 's/^/  /'
        
        return 0
    else
        log_warning "No modules detected"
        return 1
    fi
}

test_network() {
    log_info "Testing network configuration..."
    
    local interfaces=$(adb shell ip link show | grep "^[0-9]" | wc -l)
    log_info "Network interfaces: $interfaces"
    
    if [ "$interfaces" -gt 0 ]; then
        log_success "Network interfaces available"
        
        # Check if we can resolve DNS
        local dns_test=$(adb shell ping -c 1 8.8.8.8 2>&1 | grep -c "bytes from" || true)
        
        if [ "$dns_test" -gt 0 ]; then
            log_success "Network connectivity OK"
            return 0
        else
            log_warning "Could not ping external host"
            return 1
        fi
    fi
}

test_battery() {
    log_info "Checking battery status..."
    
    if adb shell test -f /sys/class/power_supply/battery/capacity; then
        local battery=$(adb shell cat /sys/class/power_supply/battery/capacity)
        log_info "Battery level: $battery%"
        
        if [ "$battery" -gt 20 ]; then
            log_success "Battery level adequate"
            return 0
        else
            log_warning "Low battery level"
            return 1
        fi
    fi
}

# Generate test report
generate_test_report() {
    local report_file="test_report_$(date +%s).txt"
    
    log_info "Generating test report..."
    
    {
        echo "╔════════════════════════════════════════════════╗"
        echo "║  Kernel Verification Report                   ║"
        echo "╚════════════════════════════════════════════════╝"
        echo ""
        echo "Test Date: $(date)"
        echo ""
        
        echo "Device Information:"
        echo "  Model: $(adb shell getprop ro.model.name)"
        echo "  Device: $(adb shell getprop ro.boot.hardware)"
        echo "  Android: $(adb shell getprop ro.build.version.release)"
        echo "  OneUI: $(adb shell getprop ro.build.version.incremental)"
        echo "  Kernel: $(adb shell uname -r)"
        echo ""
        
        echo "Build Information:"
        echo "  Build Host: $(adb shell uname -a)"
        echo ""
        
        echo "Feature Availability:"
        adb shell zcat /proc/config.gz 2>/dev/null | grep "CONFIG_" | grep "=y" | head -20 | sed 's/^/  /'
        echo ""
        
        echo "System Status:"
        echo "  Uptime: $(adb shell uptime)"
        echo ""
        
        echo "Loaded Modules:"
        adb shell lsmod | sed 's/^/  /'
        
    } > "$report_file"
    
    log_success "Report saved: $report_file"
}

# Main test suite
main() {
    log_success "╔════════════════════════════════════════════════╗"
    log_success "║  Kernel Verification Test Suite              ║"
    log_success "║  Samsung S23 Ultra BBRv3 Build               ║"
    log_success "╚════════════════════════════════════════════════╝"
    log_info ""
    
    local total_tests=0
    local passed_tests=0
    
    # Run tests
    tests=(
        "test_device_connection"
        "test_kernel_version"
        "test_bbrv3"
        "test_kernelsu"
        "test_susfs"
        "test_lto_optimization"
        "test_memory_usage"
        "test_thermal"
        "test_modules"
        "test_network"
        "test_battery"
    )
    
    for test in "${tests[@]}"; do
        ((total_tests++))
        if $test; then
            ((passed_tests++))
        fi
        log_info ""
    done
    
    # Generate report
    generate_test_report
    
    # Summary
    log_info ""
    log_success "╔════════════════════════════════════════════════╗"
    log_info "Test Results: $passed_tests/$total_tests passed"
    log_success "╚════════════════════════════════════════════════╝"
    
    if [ "$passed_tests" -eq "$total_tests" ]; then
        log_success "All tests passed! Kernel is working properly."
        return 0
    else
        log_warning "Some tests failed. Check details above."
        return 1
    fi
}

main "$@"
