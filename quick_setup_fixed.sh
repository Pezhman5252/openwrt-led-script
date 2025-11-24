#!/bin/sh
# Internet LED Controller - Quick Setup Script (Fixed Version)
# One-click installation with automatic LED detection
# Version: 7.1 - Fixed
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

# Download helper function
download_file() {
    local url="$1"
    local output="$2"
    local description="$3"
    
    echo "📥 Downloading $description..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$output" "$url" 2>/dev/null
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$output" "$url" 2>/dev/null
    else
        echo "❌ Neither wget nor curl is available"
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Downloaded successfully"
        return 0
    else
        echo "   ❌ Download failed"
        return 1
    fi
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
    
    # Check if we have the installer script locally
    if [ ! -f "./install_simple.sh" ]; then
        echo "📥 Downloading installer from GitHub..."
        base_url="https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main"
        if ! download_file "$base_url/install_simple.sh" "./install_simple.sh" "installer"; then
            echo "❌ Failed to download installer. Please check your internet connection."
            return 1
        fi
    fi
    
    chmod +x ./install_simple.sh
    echo "🔧 Running installer..."
    if ! ./install_simple.sh; then
        echo "❌ Installation failed. Please check the logs above."
        return 1
    fi
    
    echo ""
    echo "🧪 Testing installation..."
    sleep 3
    
    # Run tests if available
    if [ -f "./test_installation.sh" ]; then
        chmod +x ./test_installation.sh
        ./test_installation.sh
    else
        echo "📋 Running basic tests..."
        echo "   Service status: $(/etc/init.d/internet_led status 2>/dev/null || echo 'Not running')"
        echo "   Process check: $(ps | grep -v grep | grep internet_led_status.sh >/dev/null && echo 'Running' || echo 'Not found')"
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
        echo "❌ No LED interfaces found. Manual configuration requires LED interfaces."
        return 1
    fi
    
    echo ""
    echo "📝 LED Configuration:"
    echo "   Configure LED paths for your router:"
    echo ""
    
    # Get LED paths from user
    echo -n "LED Green path (e.g., /sys/class/leds/led0:green/brightness): "
    read -r green_path
    
    echo -n "LED Red/Amber path (e.g., /sys/class/leds/led0:red/brightness): "
    read -r red_path
    
    echo -n "LED Blue path (optional, e.g., /sys/class/leds/led0:blue/brightness): "
    read -r blue_path
    
    # Validate paths
    if [ ! -f "$green_path" ]; then
        echo "❌ Green LED path does not exist: $green_path"
        return 1
    fi
    
    if [ ! -f "$red_path" ]; then
        echo "❌ Red/Amber LED path does not exist: $red_path"
        return 1
    fi
    
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
    
    echo "✅ Configuration file created"
    
    # Check if service is installed
    if [ ! -f "/bin/internet_led_status.sh" ]; then
        echo "⚠️  Internet LED service is not installed yet."
        echo "   Please run option 1 (Automatic Setup) first to install the service."
        return 1
    fi
    
    # Restart service
    echo "🔄 Restarting service with new configuration..."
    if /etc/init.d/internet_led restart 2>/dev/null; then
        echo "✅ Service restarted successfully"
    else
        echo "⚠️  Service restart failed. Starting manually..."
        /bin/sh /bin/internet_led_status.sh &
    fi
}

# Test current installation
test_installation() {
    echo "🧪 Testing Current Installation"
    echo "==============================="
    echo ""
    
    if [ -f "./test_installation.sh" ]; then
        echo "🧪 Running comprehensive test suite..."
        chmod +x ./test_installation.sh
        ./test_installation.sh
    else
        echo "📋 Running basic tests..."
        
        # Test 1: Service status
        echo ""
        echo "1️⃣ Service Status:"
        if /etc/init.d/internet_led status >/dev/null 2>&1; then
            echo "   ✅ Service is running"
        else
            echo "   ❌ Service is not running"
        fi
        
        # Test 2: Process check
        echo ""
        echo "2️⃣ Process Check:"
        if ps | grep -v grep | grep internet_led_status.sh >/dev/null; then
            echo "   ✅ Main script process is running"
        else
            echo "   ❌ Main script process not found"
        fi
        
        # Test 3: LED paths
        echo ""
        echo "3️⃣ LED Configuration:"
        if [ -f "/etc/config/internet_led" ]; then
            echo "   ✅ Configuration file exists"
            led_green=$(grep "led_green" /etc/config/internet_led | cut -d"'" -f4)
            led_red=$(grep "led_red" /etc/config/internet_led | cut -d"'" -f4)
            led_blue=$(grep "led_blue" /etc/config/internet_led | cut -d"'" -f4)
            
            [ -f "$led_green" ] && echo "   ✅ Green LED: $led_green" || echo "   ❌ Green LED path invalid"
            [ -f "$led_red" ] && echo "   ✅ Red LED: $led_red" || echo "   ❌ Red LED path invalid"
            [ -f "$led_blue" ] && echo "   ✅ Blue LED: $led_blue" || echo "   ⚠️ Blue LED path invalid"
        else
            echo "   ❌ Configuration file not found"
        fi
        
        # Test 4: Internet connectivity
        echo ""
        echo "4️⃣ Internet Connectivity:"
        if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
            echo "   ✅ Internet connectivity is working"
        else
            echo "   ❌ No internet connectivity"
        fi
        
        # Test 5: LED functionality
        echo ""
        echo "5️⃣ LED Test:"
        if [ -f "/sys/class/leds/led1:green/brightness" ]; then
            echo "   Testing green LED..."
            echo 255 > /sys/class/leds/led1:green/brightness 2>/dev/null && echo "   ✅ Green LED works" || echo "   ❌ Green LED control failed"
            echo 0 > /sys/class/leds/led1:green/brightness 2>/dev/null
        fi
        
        if [ -f "/sys/class/leds/led1:amber/brightness" ]; then
            echo "   Testing amber LED..."
            echo 255 > /sys/class/leds/led1:amber/brightness 2>/dev/null && echo "   ✅ Amber LED works" || echo "   ❌ Amber LED control failed"
            echo 0 > /sys/class/leds/led1:amber/brightness 2>/dev/null
        fi
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
            echo "🗑️ Running complete uninstaller..."
            chmod +x ./uninstall_complete.sh
            ./uninstall_complete.sh
        else
            echo "📥 Download uninstaller from GitHub..."
            base_url="https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main"
            if download_file "$base_url/uninstall_complete.sh" "./uninstall_complete.sh" "uninstaller"; then
                chmod +x ./uninstall_complete.sh
                ./uninstall_complete.sh
            else
                echo "❌ Failed to download uninstaller"
                echo ""
                echo "🔧 Manual uninstall commands:"
                echo "   /etc/init.d/internet_led stop"
                echo "   /etc/init.d/internet_led disable"
                echo "   rm -f /etc/init.d/internet_led /bin/internet_led_status.sh /etc/config/internet_led"
                echo "   rm -f /tmp/internet_led.log /var/run/internet_led.pid"
                echo "   killall -9 internet_led_status.sh 2>/dev/null"
            fi
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
        echo "🩺 Running comprehensive diagnostics..."
        chmod +x ./troubleshoot.sh
        ./troubleshoot.sh
    else
        echo "📋 Running basic diagnostics..."
        base_url="https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main"
        
        echo ""
        echo "1️⃣ Service Status:"
        /etc/init.d/internet_led status 2>/dev/null || echo "   ❌ Service not running or not installed"
        
        echo ""
        echo "2️⃣ Process Check:"
        if ps | grep -v grep | grep internet_led_status.sh >/dev/null; then
            echo "   ✅ Main script is running"
        else
            echo "   ❌ Main script is not running"
        fi
        
        echo ""
        echo "3️⃣ LED Paths Check:"
        echo "   Looking for LED interfaces..."
        ls /sys/class/leds/ 2>/dev/null | while read led; do
            echo "   📍 $led"
        done
        
        echo ""
        echo "4️⃣ Network Connectivity Test:"
        if ping -c 3 -W 3 8.8.8.8 >/dev/null 2>&1; then
            echo "   ✅ Internet connectivity OK"
        else
            echo "   ❌ No internet connectivity"
        fi
        
        echo ""
        echo "5️⃣ Recent Errors:"
        logread | grep internet_led | tail -5 2>/dev/null || echo "   No recent entries in system log"
        
        echo ""
        echo "6️⃣ System Resources:"
        free -m | grep Mem | awk '{print "   Memory usage: " $3 "/" $2 " MB"}'
        uptime | awk '{print "   Uptime: " $3 " " $4 " " $5}'
        
        echo ""
        echo "🔧 Quick Fixes:"
        echo "   Restart service:     /etc/init.d/internet_led restart"
        echo "   View logs:          logread | grep internet_led"
        echo "   Check config:       cat /etc/config/internet_led"
        
        # Offer to download troubleshooter
        echo ""
        echo -n "Would you like to download the full troubleshooting tool? (y/N): "
        read -r response
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            if download_file "$base_url/troubleshoot.sh" "./troubleshoot.sh" "troubleshooting tool"; then
                chmod +x ./troubleshoot.sh
                echo ""
                echo "🩺 Running full diagnostics..."
                ./troubleshoot.sh
            fi
        fi
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