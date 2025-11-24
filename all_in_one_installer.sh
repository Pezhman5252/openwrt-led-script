#!/bin/sh
# Internet LED Controller - Complete All-in-One Installer
# Version: 7.1
# Author: MiniMax Agent
# 
# This single file contains all necessary code for installation, testing, and management
# No external file dependencies required!

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "⚡ Internet LED Controller - All-in-One Installer"
echo "================================================"
echo "🎯 Complete solution with no file dependencies"
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

# MAIN INSTALLATION SCRIPT (from install_simple.sh)
install_main_script() {
    echo "🚀 Installing Internet LED Controller..."
    echo ""
    
    # Create directories
    mkdir -p /bin
    mkdir -p /etc/config
    
    # Download main monitoring script
    echo "📥 Installing main monitoring script..."
    cat > /bin/internet_led_status.sh << 'EOF'
#!/bin/sh
# Internet LED Status Monitor
# Monitors internet connectivity and controls LEDs accordingly

# Default LED paths (adjust for your router model)
GREEN_LED="/sys/class/leds/led1:green/brightness"
AMBER_LED="/sys/class/leds/led1:amber/brightness"
BLUE_LED="/sys/class/leds/led0:blue/brightness"

LOG_FILE="/tmp/internet_led.log"
PING_TARGET="8.8.8.8"
CHECK_INTERVAL="10"

# Load configuration if available
if [ -f /etc/config/internet_led ]; then
    . /etc/config/internet_led 2>/dev/null
fi

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_internet() {
    if ping -c 1 -W 3 "$PING_TARGET" >/dev/null 2>&1 && nslookup google.com >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

set_led() {
    local led_path="$1"
    local value="$2"
    [ -n "$led_path" ] && echo "$value" > "$led_path" 2>/dev/null
}

show_connected() {
    # Yellow LED = Green + Blue
    set_led "$GREEN_LED" 255
    set_led "$AMBER_LED" 0
    set_led "$BLUE_LED" 255
}

show_disconnected() {
    # Red LED = Amber + Blue  
    set_led "$GREEN_LED" 0
    set_led "$AMBER_LED" 255
    set_led "$BLUE_LED" 255
}

show_off() {
    set_led "$GREEN_LED" 0
    set_led "$AMBER_LED" 0
    set_led "$BLUE_LED" 0
}

log_message "Internet LED Monitor started"

while true; do
    if check_internet; then
        show_connected
        log_message "Internet: CONNECTED"
    else
        show_disconnected
        log_message "Internet: DISCONNECTED"
    fi
    
    sleep "$CHECK_INTERVAL"
done
EOF

    # Download init.d service script
    echo "📥 Installing service script..."
    cat > /etc/init.d/internet_led << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    echo "Starting Internet LED Controller..."
    /bin/sh /bin/internet_led_status.sh &
    echo $! > /var/run/internet_led.pid
}

stop() {
    echo "Stopping Internet LED Controller..."
    if [ -f /var/run/internet_led.pid ]; then
        kill $(cat /var/run/internet_led.pid) 2>/dev/null
        rm -f /var/run/internet_led.pid
    fi
    # Turn off LEDs
    for led in /sys/class/leds/*/brightness; do
        echo 0 > "$led" 2>/dev/null
    done
}

restart() {
    stop
    sleep 2
    start
}

status() {
    if [ -f /var/run/internet_led.pid ] && kill -0 $(cat /var/run/internet_led.pid) 2>/dev/null; then
        echo "Internet LED Controller is running (PID: $(cat /var/run/internet_led.pid))"
        return 0
    else
        echo "Internet LED Controller is not running"
        return 1
    fi
}
EOF

    # Create configuration file
    echo "📥 Creating configuration..."
    cat > /etc/config/internet_led << 'EOF'
config internet_led 'main'
    option enabled '1'
    option check_interval '10'
    option led_green '/sys/class/leds/led1:green/brightness'
    option led_red '/sys/class/leds/led1:amber/brightness'
    option led_blue '/sys/class/leds/led0:blue/brightness'
    option log_file '/tmp/internet_led.log'
    option ping_target '8.8.8.8'
    option ping_timeout '3'
EOF

    # Set permissions
    chmod +x /bin/internet_led_status.sh
    chmod +x /etc/init.d/internet_led
    
    # Enable and start service
    echo "🚀 Enabling and starting service..."
    /etc/init.d/internet_led enable
    /etc/init.d/internet_led start
    
    echo "✅ Installation completed successfully!"
}

# TEST SCRIPT (from test_installation.sh)
run_comprehensive_tests() {
    echo "🧪 Internet LED Controller - Complete Installation Test"
    echo "===================================================="
    
    total_tests=0
    passed_tests=0
    failed_tests=0
    
    test_result() {
        total_tests=$((total_tests + 1))
        if [ "$1" = "pass" ]; then
            echo -e "   ${GREEN}✅ PASS${NC} - $2"
            passed_tests=$((passed_tests + 1))
        else
            echo -e "   ${RED}❌ FAIL${NC} - $2"
            failed_tests=$((failed_tests + 1))
        fi
    }
    
    echo ""
    echo -e "${BLUE}📋 Test Suite: Complete Installation Verification${NC}"
    echo ""
    
    # Test 1: Service Status
    echo -e "${YELLOW}1️⃣ Service Status Test${NC}"
    if /etc/init.d/internet_led status >/dev/null 2>&1; then
        test_result "pass" "Service is running"
        /etc/init.d/internet_led status
    else
        test_result "fail" "Service is not running"
        echo "   🔧 Try: /etc/init.d/internet_led start"
    fi
    echo ""
    
    # Test 2: Process Check
    echo -e "${YELLOW}2️⃣ Process Verification${NC}"
    if ps | grep -v grep | grep internet_led_status.sh >/dev/null; then
        test_result "pass" "Main script process is running"
        ps | grep -v grep | grep internet_led_status.sh
    else
        test_result "fail" "Main script process not found"
    fi
    echo ""
    
    # Test 3: File Existence
    echo -e "${YELLOW}3️⃣ File System Test${NC}"
    for file in "/etc/init.d/internet_led" "/bin/internet_led_status.sh" "/etc/config/internet_led"; do
        if [ -f "$file" ]; then
            test_result "pass" "File exists: $file"
        else
            test_result "fail" "File missing: $file"
        fi
    done
    echo ""
    
    # Test 4: LED Functionality
    echo -e "${YELLOW}4️⃣ LED Functionality Test${NC}"
    for led_path in "/sys/class/leds/led1:green/brightness" "/sys/class/leds/led1:amber/brightness" "/sys/class/leds/led0:blue/brightness"; do
        if [ -f "$led_path" ]; then
            test_result "pass" "LED path exists: $led_path"
            if echo 0 > "$led_path" 2>/dev/null; then
                echo "   ✅ Can control: $led_path"
            else
                echo "   ⚠️ Cannot write to: $led_path"
            fi
        else
            test_result "fail" "LED path missing: $led_path"
        fi
    done
    echo ""
    
    # Test 5: Internet Connectivity
    echo -e "${YELLOW}5️⃣ Internet Connectivity Test${NC}"
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        test_result "pass" "Internet connectivity is working"
    else
        test_result "fail" "No internet connectivity"
    fi
    echo ""
    
    # Results Summary
    echo "======================================================"
    echo -e "${BLUE}🏆 TEST RESULTS SUMMARY${NC}"
    echo "======================================================"
    echo "📊 Total Tests: $total_tests"
    echo -e "${GREEN}✅ Passed: $passed_tests${NC}"
    echo -e "${RED}❌ Failed: $failed_tests${NC}"
    
    if [ $failed_tests -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 ALL TESTS PASSED! Installation is working correctly!${NC}"
    else
        echo ""
        echo -e "${RED}⚠️ SOME TESTS FAILED - Check configuration${NC}"
    fi
    echo ""
}

# TROUBLESHOOT SCRIPT (from troubleshoot.sh)
run_diagnostics() {
    echo "🔧 Internet LED Controller - Diagnostics"
    echo "======================================"
    echo ""
    
    # Service Status
    echo "1️⃣ Service Status:"
    /etc/init.d/internet_led status 2>/dev/null || echo "   ❌ Service not running or not installed"
    echo ""
    
    # Process Check
    echo "2️⃣ Process Check:"
    if ps | grep -v grep | grep internet_led_status.sh >/dev/null; then
        echo "   ✅ Main script is running"
        ps | grep -v grep | grep internet_led_status.sh
    else
        echo "   ❌ Main script is not running"
    fi
    echo ""
    
    # LED Paths
    echo "3️⃣ LED Paths Check:"
    echo "   Looking for LED interfaces..."
    if ls /sys/class/leds/ >/dev/null 2>&1; then
        ls /sys/class/leds/ | while read led; do
            echo "   📍 $led"
        done
    else
        echo "   ❌ No LED interfaces found"
    fi
    echo ""
    
    # Internet Connectivity
    echo "4️⃣ Internet Connectivity:"
    if ping -c 3 -W 3 8.8.8.8 >/dev/null 2>&1; then
        echo "   ✅ Internet connectivity OK"
    else
        echo "   ❌ No internet connectivity"
    fi
    echo ""
    
    # System Resources
    echo "5️⃣ System Resources:"
    free -m | grep Mem | awk '{print "   Memory usage: " $3 "/" $2 " MB"}'
    uptime | awk '{print "   Uptime: " $3 " " $4 " " $5}'
    echo ""
    
    # Log Check
    echo "6️⃣ Recent Log Entries:"
    if [ -f /tmp/internet_led.log ]; then
        echo "   Log file exists:"
        tail -5 /tmp/internet_led.log | sed 's/^/     /'
    else
        echo "   ❌ Log file not found"
    fi
    echo ""
    
    echo "🔧 Quick Fixes:"
    echo "   Restart service:     /etc/init.d/internet_led restart"
    echo "   View logs:          tail -f /tmp/internet_led.log"
    echo "   Check config:       cat /etc/config/internet_led"
    echo ""
}

# UNINSTALL SCRIPT (from uninstall_complete.sh)
run_uninstall() {
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
        echo "🗑️ Starting complete uninstallation..."
        
        # Stop and disable service
        echo "   Stopping service..."
        /etc/init.d/internet_led stop 2>/dev/null
        /etc/init.d/internet_led disable 2>/dev/null
        
        # Remove files
        echo "   Removing files..."
        rm -f /etc/init.d/internet_led
        rm -f /bin/internet_led_status.sh
        rm -f /etc/config/internet_led
        rm -f /tmp/internet_led.log
        rm -f /var/run/internet_led.pid
        
        # Kill any remaining processes
        echo "   Terminating processes..."
        killall -9 internet_led_status.sh 2>/dev/null
        
        # Turn off all LEDs
        echo "   Turning off LEDs..."
        for led in /sys/class/leds/*/brightness; do
            echo 0 > "$led" 2>/dev/null
        done
        
        # Verification
        echo ""
        echo "🔍 Verifying removal..."
        if [ ! -f /bin/internet_led_status.sh ] && [ ! -f /etc/init.d/internet_led ]; then
            echo "✅ Complete uninstallation successful!"
        else
            echo "⚠️ Some files may still remain - manual cleanup may be needed"
        fi
        
        echo ""
        echo "🧹 Internet LED Controller has been completely removed"
    else
        echo "❌ Uninstall cancelled"
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
    
    # Install the main script
    install_main_script
    
    echo ""
    echo "🧪 Testing installation..."
    sleep 3
    
    # Run tests
    run_comprehensive_tests
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
    
    echo "✅ Manual configuration completed"
}

# Test current installation
test_installation() {
    echo "🧪 Testing Current Installation"
    echo "==============================="
    echo ""
    
    echo "🧪 Running comprehensive test suite..."
    run_comprehensive_tests
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
            run_uninstall
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