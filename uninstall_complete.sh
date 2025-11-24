#!/bin/sh
# Internet LED Controller - Complete Uninstaller
# Version: 7.1
# Author: MiniMax Agent

set -e

echo "🗑️ Internet LED Controller - Complete Uninstaller"
echo "================================================"

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

echo "✅ Running as root"

# Function to stop and disable service
stop_and_disable() {
    echo "🛑 Stopping Internet LED service..."
    if /etc/init.d/internet_led status >/dev/null 2>&1; then
        /etc/init.d/internet_led stop
        echo "   ✅ Service stopped"
    else
        echo "   ℹ️ Service was not running"
    fi
    
    echo "🔒 Disabling auto-start..."
    if /etc/init.d/internet_led enabled >/dev/null 2>&1; then
        /etc/init.d/internet_led disable
        echo "   ✅ Auto-start disabled"
    else
        echo "   ℹ️ Auto-start was not enabled"
    fi
}

# Function to remove files
remove_files() {
    echo "🗂️ Removing configuration files..."
    
    # Main service files
    if [ -f "/etc/init.d/internet_led" ]; then
        rm -f /etc/init.d/internet_led
        echo "   ✅ Removed init.d script"
    fi
    
    if [ -f "/bin/internet_led_status.sh" ]; then
        rm -f /bin/internet_led_status.sh
        echo "   ✅ Removed main script"
    fi
    
    if [ -f "/etc/config/internet_led" ]; then
        rm -f /etc/config/internet_led
        echo "   ✅ Removed configuration file"
    fi
    
    # Log and PID files
    if [ -f "/tmp/internet_led.log" ]; then
        rm -f /tmp/internet_led.log
        echo "   ✅ Removed log file"
    fi
    
    if [ -f "/var/run/internet_led.pid" ]; then
        rm -f /var/run/internet_led.pid
        echo "   ✅ Removed PID file"
    fi
    
    # Kill any remaining processes
    echo "🔫 Killing any remaining processes..."
    if pgrep -f internet_led_status.sh >/dev/null; then
        killall -9 internet_led_status.sh 2>/dev/null || true
        echo "   ✅ Killed remaining processes"
    fi
    
    # Turn off LEDs to clean state
    echo "💡 Turning off all LEDs..."
    for led in /sys/class/leds/*/brightness; do
        if [ -f "$led" ]; then
            echo 0 > "$led" 2>/dev/null || true
        fi
    done
    echo "   ✅ LEDs turned off"
}

# Function to verify removal
verify_removal() {
    echo "🔍 Verifying complete removal..."
    
    issues=0
    
    # Check if service files exist
    if [ -f "/etc/init.d/internet_led" ] || [ -f "/bin/internet_led_status.sh" ]; then
        echo "   ❌ Service files still exist"
        issues=$((issues + 1))
    else
        echo "   ✅ Service files removed"
    fi
    
    # Check if config exists
    if [ -f "/etc/config/internet_led" ]; then
        echo "   ❌ Configuration file still exists"
        issues=$((issues + 1))
    else
        echo "   ✅ Configuration file removed"
    fi
    
    # Check if processes running
    if pgrep -f internet_led_status.sh >/dev/null; then
        echo "   ❌ Processes still running"
        issues=$((issues + 1))
    else
        echo "   ✅ No processes running"
    fi
    
    # Check if service is enabled
    if /etc/init.d/internet_led enabled >/dev/null 2>&1; then
        echo "   ❌ Service still enabled for startup"
        issues=$((issues + 1))
    else
        echo "   ✅ Service not enabled"
    fi
    
    return $issues
}

# Main uninstall process
echo ""
echo "🔄 Starting complete uninstallation..."

# Step 1: Stop and disable service
stop_and_disable

# Step 2: Remove all files
remove_files

# Step 3: Verify removal
echo ""
verify_removal
issues=$?

# Final status
echo ""
if [ $issues -eq 0 ]; then
    echo "🎉 Uninstallation completed successfully!"
    echo "====================================="
    echo "📋 Summary:"
    echo "   ✅ Service stopped and disabled"
    echo "   ✅ All files removed"
    echo "   ✅ Processes terminated"
    echo "   ✅ LEDs turned off"
    echo ""
    echo "🚀 To reinstall in the future:"
    echo "   curl -L https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/install_simple.sh | sh"
    echo ""
    echo "ℹ️ Note: All LED colors have been reset to off"
else
    echo "⚠️ Uninstallation completed with $issues issue(s)"
    echo "================================================"
    echo "🔧 Manual cleanup may be required:"
    echo "   1. Check for remaining files: find / -name '*internet_led*' 2>/dev/null"
    echo "   2. Check for running processes: ps | grep internet_led"
    echo "   3. Reboot router if needed: reboot"
    echo ""
    exit 1
fi

echo ""
echo "🌟 Thank you for using Internet LED Controller!"
echo "   GitHub: https://github.com/Pezhman5252/openwrt-led-script"