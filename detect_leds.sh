#!/bin/sh
# LED Detection Script for OpenWRT Routers
# This script helps identify LED paths for different router models

echo "🔍 Router LED Detection Tool"
echo "==========================="

echo "📋 Router Information:"
echo "   Model: $(cat /tmp/sysinfo/board_name 2>/dev/null || echo 'Unknown')"
echo "   Hostname: $(cat /etc/hostname 2>/dev/null || echo 'Unknown')"

echo ""
echo "💡 Available LED interfaces:"
ls /sys/class/leds/ 2>/dev/null | while read led; do
    echo "   📍 $led"
    # Show brightness file if exists
    if [ -f "/sys/class/leds/$led/brightness" ]; then
        echo "      Path: /sys/class/leds/$led/brightness"
        echo "      Current value: $(cat /sys/class/leds/$led/brightness 2>/dev/null || echo 'N/A')"
    fi
done

echo ""
echo "🎮 LED Test (will flash each LED for 2 seconds):"
for led in /sys/class/leds/*/brightness; do
    led_name=$(dirname "$led")
    echo "   Testing $led_name..."
    echo 255 > "$led" 2>/dev/null
    sleep 2
    echo 0 > "$led" 2>/dev/null
done

echo ""
echo "💾 Configuration Templates:"
echo ""

echo "🔧 Google AC-1304 Configuration:"
cat << 'EOF'
config internet_led 'main'
    option enabled '1'
    option check_interval '10'
    option led_green '/sys/class/leds/led1:green/brightness'
    option led_amber '/sys/class/leds/led1:amber/brightness'
    option led_blue '/sys/class/leds/led0:blue/brightness'
    option log_file '/tmp/internet_led.log'
    option ping_target '8.8.8.8'
    option ping_timeout '3'
EOF

echo ""
echo "🔧 Generic OpenWRT Configuration:"
cat << 'EOF'
config internet_led 'main'
    option enabled '1'
    option check_interval '10'
    # LED paths vary by router model
    option led_green '/sys/class/leds/led0:green/brightness'
    option led_red '/sys/class/leds/led0:red/brightness'
    option led_blue '/sys/class/leds/led0:blue/brightness'
    option log_file '/tmp/internet_led.log'
    option ping_target '8.8.8.8'
    option ping_timeout '3'
EOF

echo ""
echo "📝 To configure for your router:"
echo "   1. Replace LED paths in /etc/config/internet_led"
echo "   2. Run: /etc/init.d/internet_led restart"
echo "   3. Monitor logs: logread | grep internet_led"