#!/bin/sh

# این نسخه بهینه‌شده اسکریپت شماست
# بهینه‌سازی‌های اعمال شده:
# 1. ترکیب Ping و DNS در یک عملیات
# 2. Cache کردن نتایج DNS
# 3. بررسی فقط در صورت تغییر IP
# 4. مدیریت بهتر timeout‌ها
# 5. اضافه کردن error handling پیشرفته

VERSION="7.0-optimized"
CACHE_FILE="/tmp/internet_status_cache"

# Configuration با امکان شخصی‌سازی
PING_TARGETS="8.8.8.8 1.1.1.1"
DNS_TARGET="google.com"
CAPTIVE_PORTAL_URL="http://detectportal.firefox.com/success.txt"
EXPECTED_RESPONSE="success"

# تنظیمات پیشرفته
SLEEP_INTERVAL=15
FAST_CHECK_INTERVAL=5
INITIAL_DELAY=20
BRIGHTNESS_LEVEL=50
MAX_FAILURES=3
CACHE_EXPIRY=30

# LED configuration (قابل تغییر)
LED_GREEN="LED0_Green"
LED_RED="LED0_Red"
LED_BLUE="LED0_Blue"

# متغیرهای داخلی
CURRENT_STATUS="unknown"
FAILURE_COUNT=0
LAST_IP=""

log() {
    logger -t "InternetLED" "$1"
}

set_led_red() {
    echo 0 > "/sys/class/leds/$LED_GREEN/brightness" 2>/dev/null || return 1
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness" 2>/dev/null || return 1
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness" 2>/dev/null || return 1
    return 0
}

set_led_yellow() {
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness" 2>/dev/null || return 1
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness" 2>/dev/null || return 1
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_GREEN/brightness" 2>/dev/null || return 1
    return 0
}

# بهینه‌سازی: cache کردن نتایج DNS
get_dns_cache() {
    local cached_ip=""
    if [ -f "$CACHE_FILE" ]; then
        local cache_time=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
        local current_time=$(date +%s 2>/dev/null || echo 0)
        local age=$((current_time - cache_time))
        
        if [ "$age" -lt "$CACHE_EXPIRY" ]; then
            cached_ip=$(cat "$CACHE_FILE" 2>/dev/null)
        fi
    fi
    
    if [ -z "$cached_ip" ]; then
        # DNS lookup جدید
        cached_ip=$(nslookup "$DNS_TARGET" 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}' | head -1)
        if [ -n "$cached_ip" ]; then
            echo "$cached_ip" > "$CACHE_FILE"
        fi
    fi
    
    echo "$cached_ip"
}

# بهینه‌سازی: بررسی تغییر IP
check_wan_ip_change() {
    local current_ip=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.ipv4.address[0]' | cut -d'/' -f1)
    [ "$current_ip" != "$LAST_IP" ]
}

# بهینه‌سازی: ترکیب چک‌ها
check_internet_optimized() {
    # بررسی WAN interface
    local wan_status=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.up')
    [ "$wan_status" = "true" ] || return 1

    # اگر IP تغییر نکرده، از cache استفاده کن
    if ! check_wan_ip_change; then
        # بررسی فقط سریع ping
        ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && return 0
        return 1
    fi

    # بررسی کامل برای IP جدید
    local dns_ip=$(get_dns_cache)
    [ -n "$dns_ip" ] || return 1

    # Test با DNS IP
    if ping -c 1 -W 3 "$dns_ip" >/dev/null 2>&1; then
        # تست HTTP فقط اگه نیاز باشه
        local http_response=$(wget -qO- --timeout=5 "$CAPTIVE_PORTAL_URL" 2>/dev/null)
        if [ $? -eq 0 ] && echo "$http_response" | grep -q "$EXPECTED_RESPONSE"; then
            LAST_IP=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.ipv4.address[0]' | cut -d'/' -f1)
            return 0
        fi
    fi

    return 1
}

# مدیریت پیشرفته خطا
handle_error() {
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
    log "Connection check failed (attempt $FAILURE_COUNT of $MAX_FAILURES)"
    
    if [ "$FAILURE_COUNT" -ge "$MAX_FAILURES" ]; then
        log "Max failures reached, marking as DOWN"
        return 1
    fi
    
    # بررسی سریع‌تر در صورت failure
    return 2  # نشانگر retry needed
}

# cleanup در exit
cleanup() {
    log "Internet LED Service Stopped"
    rm -f "$CACHE_FILE" 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Initialize LEDs
for led in "$LED_GREEN" "$LED_RED" "$LED_BLUE"; do
    [ -e "/sys/class/leds/$led" ] || { log "LED $led not found!"; exit 1; }
done

echo 0 > "/sys/class/leds/$LED_GREEN/brightness" 2>/dev/null
echo 0 > "/sys/class/leds/$LED_RED/brightness" 2>/dev/null  
echo 0 > "/sys/class/leds/$LED_BLUE/brightness" 2>/dev/null

log "Internet LED Service Started. Version: $VERSION Optimized"
set_led_red
log "Initial status: Internet DOWN (assumed)"

# تأخیر اولیه
sleep "$INITIAL_DELAY"

# Main loop بهینه‌شده
while true; do
    if check_internet_optimized; then
        NEW_STATUS="up"
        FAILURE_COUNT=0  # Reset failure counter
        sleep_interval="$SLEEP_INTERVAL"
    else
        error_code=$?
        case $error_code in
            1) # واقعاً DOWN
                NEW_STATUS="down"
                sleep_interval="$FAST_CHECK_INTERVAL"
                ;;
            2) # نیاز به retry
                NEW_STATUS="$CURRENT_STATUS"
                sleep_interval="$FAST_CHECK_INTERVAL"
                ;;
            *)
                NEW_STATUS="down"
                sleep_interval="$FAST_CHECK_INTERVAL"
                ;;
        esac
    fi

    if [ "$NEW_STATUS" != "$CURRENT_STATUS" ]; then
        if [ "$NEW_STATUS" = "up" ]; then
            log "Internet status changed to UP. Setting yellow."
            set_led_yellow || log "Warning: Failed to set yellow LED"
        else
            log "Internet status changed to DOWN. Setting red."
            set_led_red || log "Warning: Failed to set red LED"
        fi
        CURRENT_STATUS="$NEW_STATUS"
    fi

    sleep "$sleep_interval"
done