#!/bin/sh

# ===================================================================================
# اسکریپت حرفه‌ای کنترلر LED وضعیت اینترنت برای OpenWrt
# نسخه 5.1 - نهایی (رنگ زرد برای وضعیت پایدار)
#
# عملکرد:
# - در صورت اتصال کامل، چراغ زرد را به صورت ثابت و با نور ملایم روشن می‌کند.
# - در صورت بروز هرگونه مشکل، چراغ قرمز را روشن می‌کند.
# ===================================================================================

# --- بخش تنظیمات (Configuration) ---
PING_TARGETS="8.8.8.8 1.1.1.1"
DNS_CHECK_TARGET="google.com"
CAPTIVE_PORTAL_CHECK_URL="http://detectportal.firefox.com/success.txt"
EXPECTED_CAPTIVE_PORTAL_RESPONSE="success"

# --- شناسه‌های دقیق LED های روتر شما ---
LED_GREEN="LED0_Green"
LED_RED="LED0_Red"
LED_BLUE="LED0_Blue"

# --- تنظیم شدت روشنایی ---
BRIGHTNESS_LEVEL=50

# فاصله زمانی بین هر بررسی (به ثانیه).
SLEEP_INTERVAL=15

# --- توابع کنترل LED ---

# تابع روشن کردن چراغ زرد خالص (ترکیب قرمز و سبز)
set_led_yellow() {
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness"     # اطمینان از خاموش بودن آبی
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness"      # روشن کردن قرمز
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_GREEN/brightness" # روشن کردن سبز
}

# تابع روشن کردن چراغ قرمز خالص
set_led_red() {
    echo 0 > "/sys/class/leds/$LED_GREEN/brightness"    # اطمینان از خاموش بودن سبز
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness"     # اطمینان از خاموش بودن آبی
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness"  # روشن کردن قرمز
}

# --- حلقه اصلی برنامه (Main Loop) ---
log() {
    logger -t "InternetLED" "$1"
}

log "اسکریپت کنترلر LED (رنگ زرد) با موفقیت آغاز به کار کرد."

# در ابتدای کار، یک بار تمام چراغ‌ها را خاموش می‌کنیم.
echo 0 > "/sys/class/leds/$LED_GREEN/brightness"
echo 0 > "/sys/class/leds/$LED_RED/brightness"
echo 0 > "/sys/class/leds/$LED_BLUE/brightness"

while true; do
    ping_ok=0; dns_ok=0; captive_portal_ok=0

    # 1. بررسی Ping
    for target in $PING_TARGETS; do
        if ping -c 2 -W 3 "$target" >/dev/null 2>&1; then ping_ok=1; break; fi
    done

    # 2. بررسی DNS
    if nslookup "$DNS_CHECK_TARGET" >/dev/null 2>&1; then dns_ok=1; fi

    # 3. بررسی Captive Portal
    response=$(wget -qO- --timeout=5 "$CAPTIVE_PORTAL_CHECK_URL")
    if [ "$?" -eq 0 ] && echo "$response" | grep -q "$EXPECTED_CAPTIVE_PORTAL_RESPONSE"; then
        captive_portal_ok=1
    fi

    # --- تصمیم‌گیری نهایی ---
    if [ "$ping_ok" -eq 1 ] && [ "$dns_ok" -eq 1 ] && [ "$captive_portal_ok" -eq 1 ]; then
        # وضعیت: اینترنت برقرار است.
        # برای جلوگیری از نوشتن‌های بی‌دلیل، تنها در صورتی چراغ را زرد می‌کنیم که از قبل در حالت قرمز (یعنی سبز خاموش) باشد.
        if [ "$(cat /sys/class/leds/$LED_GREEN/brightness)" -eq 0 ]; then
            log "وضعیت اینترنت: پایدار. تغییر رنگ به زرد."
            set_led_yellow # <-- فراخوانی تابع جدید
        fi
    else
        # وضعیت: اینترنت قطع است.
        if [ "$(cat /sys/class/leds/$LED_RED/brightness)" -eq 0 ]; then
            log "وضعیت اینترنت: قطع. Ping=$ping_ok, DNS=$dns_ok, Portal=$captive_portal_ok. تغییر رنگ به قرمز."
            set_led_red
        fi
    fi

    sleep "$SLEEP_INTERVAL"
done
