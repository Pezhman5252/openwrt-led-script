#!/bin/sh
# Internet LED Controller - Complete Installation Test
# Version: 7.1
# Author: MiniMax Agent

echo "🧪 Internet LED Controller - Complete Installation Test"
echo "===================================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
total_tests=0
passed_tests=0
failed_tests=0

# Test function
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
echo "======================="
if /etc/init.d/internet_led status >/dev/null 2>&1; then
    test_result "pass" "Service is running"
    echo "   📋 Service details:"
    /etc/init.d/internet_led status
else
    test_result "fail" "Service is not running"
    echo "   🔧 Try: /etc/init.d/internet_led start"
fi
echo ""

# Test 2: Process Check
echo -e "${YELLOW}2️⃣ Process Verification${NC}"
echo "========================"
if ps | grep -v grep | grep internet_led_status.sh >/dev/null; then
    test_result "pass" "Main script process is running"
    echo "   📋 Process details:"
    ps | grep -v grep | grep internet_led_status.sh
else
    test_result "fail" "Main script process not found"
fi
echo ""

# Test 3: File Existence
echo -e "${YELLOW}3️⃣ File System Test${NC}"
echo "====================="

for file in "/etc/init.d/internet_led" "/bin/internet_led_status.sh" "/etc/config/internet_led"; do
    if [ -f "$file" ]; then
        test_result "pass" "File exists: $file"
    else
        test_result "fail" "File missing: $file"
    fi
done
echo ""

# Test 4: Permissions
echo -e "${YELLOW}4️⃣ Permission Test${NC}"
echo "===================="
for file in "/etc/init.d/internet_led" "/bin/internet_led_status.sh"; do
    if [ -x "$file" ]; then
        test_result "pass" "File is executable: $file"
    else
        test_result "fail" "File not executable: $file"
    fi
done
echo ""

# Test 5: LED Paths
echo -e "${YELLOW}5️⃣ LED Configuration Test${NC}"
echo "==========================="

for led_path in "/sys/class/leds/led1:green/brightness" "/sys/class/leds/led1:amber/brightness" "/sys/class/leds/led0:blue/brightness"; do
    if [ -f "$led_path" ]; then
        test_result "pass" "LED path exists: $led_path"
        # Test if we can write to it
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

# Test 6: Internet Connectivity
echo -e "${YELLOW}6️⃣ Internet Connectivity Test${NC}"
echo "==============================="
if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
    test_result "pass" "Internet connectivity is working"
else
    test_result "fail" "No internet connectivity"
fi
echo ""

# Test 7: DNS Resolution
echo -e "${YELLOW}7️⃣ DNS Resolution Test${NC}"
echo "========================"
if nslookup google.com >/dev/null 2>&1; then
    test_result "pass" "DNS resolution is working"
else
    test_result "fail" "DNS resolution failed"
fi
echo ""

# Test 8: LED Functionality Test
echo -e "${YELLOW}8️⃣ LED Functionality Test${NC}"
echo "============================"
echo "   💡 Testing LED control (will flash each LED)..."

# Test each LED
for led_color in green amber blue; do
    led_path=""
    case "$led_color" in
        green)   led_path="/sys/class/leds/led1:green/brightness" ;;
        amber)   led_path="/sys/class/leds/led1:amber/brightness" ;;
        blue)    led_path="/sys/class/leds/led0:blue/brightness" ;;
    esac
    
    if [ -f "$led_path" ]; then
        echo "   Testing $led_color LED..."
        # Turn on
        echo 255 > "$led_path" 2>/dev/null && sleep 1
        current=$(cat "$led_path" 2>/dev/null || echo "0")
        
        if [ "$current" = "255" ]; then
            test_result "pass" "$led_color LED can be turned on"
            # Turn off
            echo 0 > "$led_path" 2>/dev/null
            sleep 0.5
        else
            test_result "fail" "$led_color LED control failed"
        fi
    else
        test_result "fail" "$led_color LED path not found"
    fi
done
echo ""

# Test 9: Logging
echo -e "${YELLOW}9️⃣ Logging Test${NC}"
echo "================="
if [ -f "/tmp/internet_led.log" ]; then
    test_result "pass" "Log file exists"
    log_entries=$(wc -l < /tmp/internet_led.log 2>/dev/null || echo "0")
    echo "   📊 Log entries: $log_entries"
    
    if [ "$log_entries" -gt 0 ]; then
        test_result "pass" "Log file has entries"
        echo "   📄 Last log entry:"
        tail -1 /tmp/internet_led.log
    else
        test_result "fail" "Log file is empty"
    fi
else
    test_result "fail" "Log file does not exist"
fi
echo ""

# Test 10: Auto-start Configuration
echo -e "${YELLOW}🔟 Auto-start Test${NC}"
echo "===================="
if /etc/init.d/internet_led enabled >/dev/null 2>&1; then
    test_result "pass" "Service is enabled for auto-start"
else
    test_result "fail" "Service is not enabled for auto-start"
    echo "   🔧 Fix: /etc/init.d/internet_led enable"
fi
echo ""

# Performance Test
echo -e "${YELLOW}📊 Performance Test${NC}"
echo "===================="
if pgrep -f internet_led_status.sh >/dev/null; then
    pid=$(pgrep -f internet_led_status.sh | head -1)
    if [ -n "$pid" ]; then
        cpu_info=$(ps -p $pid -o %cpu= 2>/dev/null | tr -d ' ')
        mem_info=$(ps -p $pid -o %mem= 2>/dev/null | tr -d ' ')
        
        echo "   💻 CPU Usage: $cpu_info%"
        echo "   💾 Memory Usage: $mem_info%"
        
        # Check if resource usage is reasonable
        if [ -n "$cpu_info" ] && [ "${cpu_info%.*}" -lt 10 ]; then
            test_result "pass" "CPU usage is acceptable (<10%)"
        else
            test_result "fail" "CPU usage may be too high"
        fi
        
        if [ -n "$mem_info" ] && [ "${mem_info%.*}" -lt 5 ]; then
            test_result "pass" "Memory usage is acceptable (<5%)"
        else
            test_result "fail" "Memory usage may be too high"
        fi
    fi
else
    test_result "fail" "Cannot check performance - process not running"
fi
echo ""

# Test Results Summary
echo "======================================================"
echo -e "${BLUE}🏆 TEST RESULTS SUMMARY${NC}"
echo "======================================================"
echo "📊 Total Tests: $total_tests"
echo -e "${GREEN}✅ Passed: $passed_tests${NC}"
echo -e "${RED}❌ Failed: $failed_tests${NC}"

if [ $failed_tests -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Installation is working correctly!${NC}"
    echo ""
    echo "🌐 LED Status Indicators:"
    echo "   🟡 Yellow = Internet Connected"
    echo "   🔴 Red = Internet Disconnected"
    echo ""
    echo "📋 Available Commands:"
    echo "   /etc/init.d/internet_led status   - Check service status"
    echo "   /etc/init.d/internet_led restart  - Restart service"
    echo "   logread | grep internet_led       - View logs"
    echo ""
elif [ $failed_tests -le 3 ]; then
    echo ""
    echo -e "${YELLOW}⚠️ MINOR ISSUES DETECTED${NC}"
    echo "   Most functionality is working, but $failed_tests test(s) failed"
    echo "   Review failed tests above and run troubleshooting if needed"
else
    echo ""
    echo -e "${RED}🚨 MAJOR ISSUES DETECTED${NC}"
    echo "   $failed_tests tests failed - installation may not be working correctly"
    echo "   Run troubleshooting script: ./troubleshoot.sh"
    echo "   Or reinstall: ./install_simple.sh"
fi

echo ""
echo "📚 Documentation: See INSTALLATION_GUIDE.md for detailed information"