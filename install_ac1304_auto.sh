#!/bin/sh

# نصب یک‌دستوری Internet LED برای AC-1304
echo "🚀 Installing Internet LED Controller for AC-1304..."

# بررسی اتصال
ping -c 1 8.8.8.8 >/dev/null 2>&1 || { echo "❌ No internet"; exit 1; }

# دانلود و نصب
wget -qO- https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/install_internet_led_premium.sh | sh

# تنظیم AC-1304
sleep 3

# بررسی LEDهای موجود
LED_GREEN=""
LED_RED=""
LED_BLUE=""

for led in /sys/class/leds/*/brightness; do
    led_name=$(basename "$(dirname "$led")")
    case $led_name in
        *green*) LED_GREEN=$led_name ;;
        *amber*) LED_RED=$led_name ;;
        *red*) LED_RED=$led_name ;;
        *blue*) LED_BLUE=$led_name ;;
    esac
done

echo "Found LEDs: Green=$LED_GREEN, Red=$LED_RED, Blue=$LED_BLUE"

# تنظیم config
if [ -n "$LED_GREEN" ] && [ -n "$LED_RED" ]; then
    uci set internet_led.main.led_green="$LED_GREEN"
    uci set internet_led.main.led_red="$LED_RED"
    uci set internet_led.main.led_blue="${LED_BLUE:-"led0:blue"}"
    uci set internet_led.main.brightness='30'
    uci set internet_led.main.sleep_interval='20'
    uci commit internet_led
    
    # ریستارت
    /etc/init.d/internet_led restart
    
    echo "✅ Configuration applied for AC-1304"
    echo "🎉 Installation completed!"
    echo
    echo "📋 Test commands:"
    echo "  Status: /etc/init.d/internet_led status"
    echo "  Logs: logread | grep InternetLED"
    echo "  Monitor: /tmp/ac1304_monitor.sh"
else
    echo "⚠️  Please configure LEDs manually in /etc/config/internet_led"
fi