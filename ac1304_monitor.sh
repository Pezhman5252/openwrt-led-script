#!/bin/sh

# Internet LED Monitor for AC-1304
# این اسکریپت رو روی روتر اجرا کنید

MONITOR_TAG="InternetLED"

echo "🔍 AC-1304 Internet LED Status Monitor"
echo "======================================"
echo

# Service Status
echo "📊 Service Status:"
if /etc/init.d/internet_led status >/dev/null 2>&1; then
    echo "✅ Service is running"
    PID=$(pgrep -f "internet_led_status.sh" | head -1)
    if [ -n "$PID" ]; then
        echo "📍 Process ID: $PID"
        MEMORY=$(ps -p $PID -o rss= | awk '{print int($1/1024)}')
        echo "🧠 Memory: ${MEMORY}MB"
        CPU=$(ps -p $PID -o %cpu= | awk '{print $1"%"}')
        echo "⚡ CPU: $CPU"
    fi
else
    echo "❌ Service is not running"
    echo "Start with: /etc/init.d/internet_led start"
fi

echo

# WAN Interface Status
echo "🌐 WAN Interface:"
WAN_STATUS=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.up')
WAN_IP=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.ipv4.address[0]' | cut -d'/' -f1)
echo "Status: $([ "$WAN_STATUS" = "true" ] && echo "UP" || echo "DOWN")"
echo "IP: ${WAN_IP:-"Not assigned"}"

echo

# LED Status
echo "💡 LED Status:"
for led in led1:green led1:amber led0:blue; do
    if [ -e "/sys/class/leds/$led/brightness" ]; then
        BRIGHTNESS=$(cat "/sys/class/leds/$led/brightness" 2>/dev/null)
        echo "  $led: brightness=$BRIGHTNESS"
    else
        echo "  $led: Not found"
    fi
done

echo

# Internet Test
echo "📡 Internet Test:"
for target in 8.8.8.8 1.1.1.1 google.com; do
    if ping -c 1 -W 2 "$target" >/dev/null 2>&1; then
        echo "  ✅ $target - OK"
    else
        echo "  ❌ $target - FAILED"
    fi
done

echo

# Recent Logs
echo "📋 Recent Activity (last 5 entries):"
logread | grep "$MONITOR_TAG" | tail -5 | while read -r line; do
    echo "  $line"
done

echo
echo "======================================"