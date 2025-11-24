#!/bin/sh
# Internet LED Troubleshooting Script

echo "🔧 Internet LED Troubleshooting Tool"
echo "===================================="

echo ""
echo "1️⃣ Service Status Check:"
echo "========================"
/etc/init.d/internet_led status 2>/dev/null || echo "❌ Service not running or not installed"

echo ""
echo "2️⃣ Process Check:"
echo "================="
if ps | grep -v grep | grep internet_led_status.sh > /dev/null; then
    echo "✅ Main script is running"
    ps | grep -v grep | grep internet_led_status.sh
else
    echo "❌ Main script is not running"
fi

echo ""
echo "3️⃣ LED Paths Check:"
echo "==================="
echo "   Looking for LED interfaces..."
for led in green amber red blue; do
    led_path=$(grep "led_$led" /etc/config/internet_led 2>/dev/null | cut -d"'" -f4)
    if [ -n "$led_path" ] && [ -f "$led_path" ]; then
        echo "   ✅ $led LED: $led_path (value: $(cat "$led_path" 2>/dev/null || echo 'N/A'))"
    elif [ -n "$led_path" ]; then
        echo "   ❌ $led LED path not found: $led_path"
    fi
done

echo ""
echo "4️⃣ Network Connectivity Test:"
echo "=============================="
echo "   Ping test to 8.8.8.8:"
if ping -c 3 -W 3 8.8.8.8 >/dev/null 2>&1; then
    echo "   ✅ Internet connectivity OK"
else
    echo "   ❌ No internet connectivity"
fi

echo "   DNS test:"
if nslookup google.com >/dev/null 2>&1; then
    echo "   ✅ DNS resolution OK"
else
    echo "   ❌ DNS resolution failed"
fi

echo ""
echo "5️⃣ Log Analysis:"
echo "================"
if [ -f /tmp/internet_led.log ]; then
    echo "   📄 Last 10 log entries:"
    tail -10 /tmp/internet_led.log 2>/dev/null || echo "   ❌ Cannot read log file"
else
    echo "   ❌ Log file not found"
fi

echo ""
echo "6️⃣ System Resources:"
echo "===================="
echo "   Memory usage:"
free -m | grep Mem | awk '{print "   Used: " $3 "MB / " $2 "MB (" int($3/$2*100) "%)"}'

echo "   CPU load:"
uptime | awk '{print "   Load: " $8 " " $9 " " $10 " (1m 5m 15m)"}'

echo ""
echo "7️⃣ Recent Errors:"
echo "================="
echo "   System logs (last 5 internet_led entries):"
logread | grep internet_led | tail -5 2>/dev/null || echo "   No recent entries in system log"

echo ""
echo "🔧 Quick Fixes:"
echo "==============="
echo "   Restart service:     /etc/init.d/internet_led restart"
echo "   View logs:          logread | grep internet_led"
echo "   Manual test:        /bin/internet_led_status.sh"
echo "   Check config:       cat /etc/config/internet_led"
echo ""

# Offer to fix common issues
echo "🎯 Would you like to try automatic fixes?"
echo "   1. Restart the service"
echo "   2. Reset LED configuration"
echo "   3. Clear logs and restart"
echo "   4. Nothing (exit)"
echo ""
echo -n "Select option (1-4): "