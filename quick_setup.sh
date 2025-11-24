#!/bin/sh
# Internet LED Controller - Quick Setup Script
# One-click installation with automatic LED detection
# Version: 7.1
# Author: MiniMax Agent

set -e

echo "⚡ Internet LED Controller - Quick Setup"
echo "======================================="
echo "🎯 One-click installation with automatic LED detection"
echo ""

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root"
    echo "💡 Usage: ssh root@192.168.1.1"
    exit 1
fi

# Menu system
show_menu() {
    echo "🔧 Select installation option:"
    echo "   1️⃣  Automatic Setup (Recommended)"
    echo "   2️⃣  Manual LED Configuration" 
    echo "   3️⃣  Test Current Installation"
    echo "   4️⃣  Uninstall Completely"
    echo "   5️⃣  Run Diagnostics"
    echo "   6️⃣  Exit"
    echo ""
    echo -n "Choose option (1-6): "
}

# Automatic setup function
automatic_setup() {
    echo "🔄 Running automatic setup..."
    echo ""
    
    echo "📋 System Information:"
    echo "   Router Model: $(cat /tmp/sysinfo/board_name 2>/dev/null || echo 'Unknown')"
    echo "   OpenWRT Version: $(cat /etc/openwrt_version 2>/dev/null || echo 'Unknown')"
    echo ""
    
    echo "💡 Detecting available LEDs..."
    led_count=$(ls /sys/class/leds/*/brightness 2>/dev/null | wc -l)
    echo "   Found $led_count LED interface(s)"
    
    if [ "$led_count" -eq 0 ]; then
        echo "   ⚠️  No LED interfaces found - this router may not support LED control"
        echo "   Continue anyway? (y/N)"
        read -r response
        if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
            echo "❌ Setup cancelled"
            return 1
        fi
    else
        echo "   Available LEDs:"
        ls /sys/class/leds/ 2>/dev/null | sed 's/^/      📍 /'
    fi
    
    echo ""
    echo "🚀 Installing Internet LED Controller..."
    
    # Run the main installer
    if [ -f "./install_simple.sh" ]; then
        chmod +x ./install_simple.sh
        ./install_simple.sh
    else
        echo "❌ install_simple.sh not found in current directory"
        return 1
    fi
    
    echo ""
    echo "🧪 Testing installation..."
    sleep 3
    
    # Run tests
    if [ -f "./test_installation.sh" ]; then
        chmod +x ./test_installation.sh
        ./test_installation.sh
    fi
}

# Manual configuration function
manual_config() {
    echo "🔧 Manual LED Configuration"
    echo "=========================="
    echo ""
    
    echo "💡 Detecting LED interfaces..."
    leds_found=0
    for led in /sys/class/leds/*/brightness; do
        if [ -f "$led" ]; then
            led_name=$(dirname "$led")
            echo "   📍 $led_name"
            leds_found=$((leds_found + 1))
            
            # Test the LED
            echo 255 > "$led" 2>/dev/null
            sleep 1
            echo 0 > "$led" 2>/dev/null
        fi
    done
    
    if [ "$leds_found" -eq 0 ]; then
        echo "❌ No LED interfaces found"
        return 1
    fi
    
    echo ""
    echo "📝 LED Configuration:"
    echo "   Configure LED paths for your router:"
    echo ""
    
    # Get LED paths from user
    echo -n "LED Green path (e.g., /sys/class/leds/led0:green/brightness): "
    read -r green_path
    
    echo -n "LED Red/Amber path (e.g., /sys.class/leds/led0:red/brightness): "
    read -r red_path
    
    echo -n "LED Blue path (optional, e.g., /sys/class/leds/led0:blue/brightness): "
    read -r blue_path
    
    # Create custom config
    echo "📝 Creating custom configuration..."
    cat > /etc/config/internet_led << EOF
config internet_led 'main'
    option enabled '1'
    option check_interval '10'
    option led_green '$green_path'
    option led_red '$red_path'
    option led_blue '$blue_path'
    option log_file '/tmp/internet_led.log'
    option ping_target '8.8.8.8'
    option ping_timeout '3'
EOF
    
    # Restart service
    echo "🔄 Restarting service with new configuration..."
    /etc/init.d/internet_led restart
    
    echo "✅ Manual configuration completed"
}

# Test current installation
test_installation() {
    echo "🧪 Testing Current Installation"
    echo "==============================="
    echo ""
    
    if [ -f "./test_installation.sh" ]; then
        chmod +x ./test_installation.sh
        ./test_installation.sh
    else
        echo "❌ test_installation.sh not found"
        echo ""
        echo "Manual test commands:"
        echo "   /etc/init.d/internet_led status"
        echo "   logread | grep internet_led"
        echo "   ps | grep internet_led"
    fi
}

# Uninstall function
uninstall() {
    echo "🗑️ Complete Uninstall"
    echo "===================="
    echo ""
    echo "⚠️  This will completely remove Internet LED Controller"
    echo "   All configuration and logs will be deleted"
    echo "   LEDs will be turned off"
    echo ""
    echo -n "Are you sure? (yes/NO): "
    read -r response
    
    if [ "$response" = "yes" ]; then
        if [ -f "./uninstall_complete.sh" ]; then
            chmod +x ./uninstall_complete.sh
            ./uninstall_complete.sh
        else
            echo "❌ uninstall_complete.sh not found"
            echo ""
            echo "Manual uninstall commands:"
            echo "   /etc/init.d/internet_led stop"
            echo "   /etc/init.d/internet_led disable"
            echo "   rm -f /etc/init.d/internet_led /bin/internet_led_status.sh /etc/config/internet_led"
        fi
    else
        echo "❌ Uninstall cancelled"
    fi
}

# Diagnostics function
run_diagnostics() {
    echo "🔧 Running Diagnostics"
    echo "===================="
    echo ""
    
    if [ -f "./troubleshoot.sh" ]; then
        chmod +x ./troubleshoot.sh
        ./troubleshoot.sh
    else
        echo "❌ troubleshoot.sh not found"
        echo ""
        echo "Basic diagnostics:"
        echo "   /etc/init.d/internet_led status"
        echo "   logread | tail -20"
        echo "   ls -la /sys/class/leds/"
        echo "   free -m"
    fi
}

# Main menu loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            echo ""
            automatic_setup
            echo ""
            echo "✅ Setup completed! Press Enter to return to menu..."
            read -r
            ;;
        2)
            echo ""
            manual_config
            echo ""
            echo "✅ Configuration completed! Press Enter to return to menu..."
            read -r
            ;;
        3)
            echo ""
            test_installation
            echo ""
            echo "✅ Test completed! Press Enter to return to menu..."
            read -r
            ;;
        4)
            echo ""
            uninstall
            echo ""
            echo "✅ Uninstall completed! Press Enter to return to menu..."
            read -r
            ;;
        5)
            echo ""
            run_diagnostics
            echo ""
            echo "✅ Diagnostics completed! Press Enter to return to menu..."
            read -r
            ;;
        6)
            echo ""
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid option. Please choose 1-6."
            echo "Press Enter to continue..."
            read -r
            ;;
    esac
    
    echo ""
    echo "============================================="
    echo ""
done