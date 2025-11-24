#!/bin/sh

# Internet LED Controller Uninstall Script v7.0
# حذف کامل سرویس از سیستم

VERSION="7.0"
SERVICE_NAME="internet_led"
INSTALL_DIR="/usr/bin"
CONFIG_DIR="/etc/config"
INIT_DIR="/etc/init.d"
SERVICE_DIR="/etc/hotplug.d/iface"
CACHE_FILE="/tmp/internet_status_cache"

echo "🗑️  Internet LED Controller Uninstall v$VERSION"
echo "=================================================="

# بررسی دسترسی root
if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root!"
    exit 1
fi

echo "📋 Stopping and disabling service..."
/etc/init.d/$SERVICE_NAME stop >/dev/null 2>&1
/etc/init.d/$SERVICE_NAME disable >/dev/null 2>&1

echo "📁 Removing files..."
# حذف فایل‌های اصلی
rm -f "$INIT_DIR/$SERVICE_NAME" 2>/dev/null
rm -f "$INSTALL_DIR/internet_led_status.sh" 2>/dev/null
rm -f "$CONFIG_DIR/internet_led" 2>/dev/null
rm -f "$SERVICE_DIR/99-internet-led" 2>/dev/null

# حذف فایل‌های اضافی
rm -f "$CACHE_FILE" 2>/dev/null
rm -f "/root/internet_led_monitor.sh" 2>/dev/null
rm -f "/root/ac1304_monitor.sh" 2>/dev/null

echo "🧹 Cleaning up..."
# پاک کردن uci settings
uci delete internet_led.main >/dev/null 2>&1
uci commit >/dev/null 2>&1

echo
echo "✅ Internet LED Controller has been completely removed!"
echo
echo "📊 Summary of removed files:"
echo "  - Service: $INIT_DIR/$SERVICE_NAME"
echo "  - Script: $INSTALL_DIR/internet_led_status.sh"
echo "  - Config: $CONFIG_DIR/internet_led"
echo "  - Cache: $CACHE_FILE"
echo "  - Hotplug: $SERVICE_DIR/99-internet-led"
echo
echo "To reinstall, run:"
echo "  wget -O - https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_internet_led_premium.sh | sh"
echo
echo "=================================================="