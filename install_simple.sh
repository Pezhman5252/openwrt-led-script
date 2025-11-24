#!/bin/sh
# Simple Internet LED Installer for OpenWRT Routers
# Version: 7.1 - Universal Installer
# Author: MiniMax Agent

set -e

echo "🌐 Internet LED Controller - Simple Universal Installer"
echo "==============================================="

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

echo "✅ Running as root"

# Create directories if they don't exist
mkdir -p /bin /etc/config

# Download internet_led_status.sh (main script)
echo "📥 Downloading internet_led_status.sh..."
cat > /bin/internet_led_status.sh << 'EOF'
#!/bin/sh

# LED paths for Google AC-1304 (can be customized)
GREEN_LED="/sys/class/leds/led1:green/brightness"
AMBER_LED="/sys/class/leds/led1:amber/brightness"
BLUE_LED="/sys/class/leds/led0:blue/brightness"

# Configuration variables
SLEEP_INTERVAL=10
DNS_CACHE_TIME=300
LAST_LED_STATE=""
PID_FILE="/var/run/internet_led.pid"

# Write PID file
echo $$ > "$PID_FILE"

# Internet check function
check_internet() {
    # Multiple checks for reliability
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        return 0  # Internet available
    elif nslookup google.com >/dev/null 2>&1; then
        return 0  # DNS check passed
    else
        return 1  # Internet unavailable
    fi
}

# LED control functions
set_led_yellow() {
    # Yellow = Green + Blue (no Amber)
    echo 255 > "$GREEN_LED" 2>/dev/null || true
    echo 0 > "$AMBER_LED" 2>/dev/null || true  
    echo 255 > "$BLUE_LED" 2>/dev/null || true
}

set_led_red() {
    # Red = Amber + Blue (no Green)
    echo 0 > "$GREEN_LED" 2>/dev/null || true
    echo 255 > "$AMBER_LED" 2>/dev/null || true
    echo 255 > "$BLUE_LED" 2>/dev/null || true
}

set_led_off() {
    # Turn off all LEDs
    echo 0 > "$GREEN_LED" 2>/dev/null || true
    echo 0 > "$AMBER_LED" 2>/dev/null || true
    echo 0 > "$BLUE_LED" 2>/dev/null || true
}

# Main monitoring loop
main_loop() {
    echo "🚀 Starting Internet LED monitoring..."
    echo "📁 Log file: /tmp/internet_led.log"
    
    while true; do
        # Check internet status
        if check_internet; then
            CURRENT_STATE="online"
            LED_STATE="yellow"
            MESSAGE="Internet: ✅ Connected"
        else
            CURRENT_STATE="offline"
            LED_STATE="red"
            MESSAGE="Internet: ❌ Disconnected"
        fi
        
        # Update LED only if state changed
        if [ "$LED_STATE" != "$LAST_LED_STATE" ]; then
            case "$LED_STATE" in
                yellow)
                    set_led_yellow
                    echo "$(date): Setting LED to YELLOW - $MESSAGE" >> /tmp/internet_led.log
                    ;;
                red)
                    set_led_red
                    echo "$(date): Setting LED to RED - $MESSAGE" >> /tmp/internet_led.log
                    ;;
            esac
            LAST_LED_STATE="$LED_STATE"
        fi
        
        # Log status every 60 seconds
        if [ $(( $(date +%s) % 60 )) -eq 0 ]; then
            echo "$(date): $MESSAGE" >> /tmp/internet_led.log
        fi
        
        sleep $SLEEP_INTERVAL
    done
}

# Cleanup on exit
cleanup() {
    echo "🔄 Shutting down Internet LED service..."
    set_led_off
    rm -f "$PID_FILE"
    exit 0
}

# Set trap for cleanup
trap cleanup SIGTERM SIGINT

# Start main loop
main_loop
EOF

# Download init.d service script
echo "📥 Downloading init.d service script..."
cat > /etc/init.d/internet_led << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    /bin/sh /bin/internet_led_status.sh &
    echo "🌐 Internet LED service started"
}

stop() {
    killall -9 internet_led_status.sh 2>/dev/null
    # Turn off LEDs when stopping
    echo 0 > /sys/class/leds/led1:green/brightness 2>/dev/null || true
    echo 0 > /sys/class/leds/led1:amber/brightness 2>/dev/null || true
    echo 0 > /sys/class/leds/led0:blue/brightness 2>/dev/null || true
    echo "🛑 Internet LED service stopped"
}

status() {
    if ps | grep -v grep | grep internet_led_status.sh > /dev/null; then
        echo "✅ Internet LED service is running"
        if [ -f /var/run/internet_led.pid ]; then
            echo "📋 PID: $(cat /var/run/internet_led.pid)"
        fi
        return 0
    else
        echo "❌ Internet LED service is not running"
        return 1
    fi
}

restart() {
    stop
    sleep 2
    start
}
EOF

# Create config file
echo "📝 Creating configuration file..."
cat > /etc/config/internet_led << 'EOF'
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

# Set permissions
echo "🔐 Setting permissions..."
chmod +x /bin/internet_led_status.sh
chmod +x /etc/init.d/internet_led

# Enable and start service
echo "🚀 Enabling and starting service..."
/etc/init.d/internet_led enable
/etc/init.d/internet_led start

# Test LEDs
echo "🧪 Testing LED functionality..."
echo "   Testing GREEN LED..."
echo 255 > /sys/class/leds/led1:green/brightness 2>/dev/null && echo "   ✅ GREEN LED OK" || echo "   ❌ GREEN LED FAILED"
sleep 1
echo 0 > /sys/class/leds/led1:green/brightness

echo "   Testing AMBER LED..."
echo 255 > /sys/class/leds/led1:amber/brightness 2>/dev/null && echo "   ✅ AMBER LED OK" || echo "   ❌ AMBER LED FAILED"
sleep 1
echo 0 > /sys/class/leds/led1:amber/brightness

echo "   Testing BLUE LED..."
echo 255 > /sys/class/leds/led0:blue/brightness 2>/dev/null && echo "   ✅ BLUE LED OK" || echo "   ❌ BLUE LED FAILED"
sleep 1
echo 0 > /sys/class/leds/led0:blue/brightness

# Show final status
echo ""
echo "🎉 Installation completed successfully!"
echo "=========================================="
/etc/init.d/internet_led status

echo ""
echo "📋 Available commands:"
echo "   /etc/init.d/internet_led start    - Start service"
echo "   /etc/init.d/internet_led stop     - Stop service"  
echo "   /etc/init.d/internet_led restart  - Restart service"
echo "   /etc/init.d/internet_led status   - Check status"
echo "   logread | grep internet_led       - View logs"
echo ""
echo "📁 Configuration file: /etc/config/internet_led"
echo "📁 Log file: /tmp/internet_led.log"
echo ""
echo "🌐 LED Status:"
echo "   🟡 Yellow = Internet Connected"
echo "   🔴 Red = Internet Disconnected"
echo ""
echo "⚠️  Note: If LEDs don't work, check your router's LED paths in config file"