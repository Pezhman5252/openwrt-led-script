#!/bin/sh

# ===================================================================================
# اسکریپت حرفه‌ای کنترلر LED وضعیت اینترنت برای OpenWrt
# نسخه 5.2 - نهایی (با منطق اصلاح شده برای تعویض رنگ قرمز/زرد)
#
# عملکرد:
# - در صورت اتصال کامل، چراغ زرد (قرمز+سبز) را به صورت ثابت روشن می‌کند.
# - در صورت بروز هرگونه مشکل، چراغ قرمز خالص را روشن می‌کند.
# - منطق تعویض رنگ به طور کامل بازنویسی و اشکال‌زدایی شده است.
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

# --- توابع کنترل LED (بدون تغییر) ---

# تابع روشن کردن چراغ زرد خالص (ترکیب قرمز و سبز)
set_led_yellow() {
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness"
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness"
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_GREEN/brightness"
}

# تابع روشن کردن چراغ قرمز خالص
set_led_red() {
    echo 0 > "/sys/class/leds/$LED_GREEN/brightness"
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness"
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness"
}

# --- حلقه اصلی برنامه (Main Loop) ---
log() {
    logger -t "InternetLED" "$1"
}

log "اسکریپت کنترلر LED (قرمز/زرد) با منطق جدید آغاز به کار کرد."

# اطمینان از خاموش بودن همه چراغ‌ها در ابتدای کار
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

    # --- بخش تصمیم‌گیری نهایی با منطق اصلاح‌شده ---
    if [ "$ping_ok" -eq 1 ] && [ "$dns_ok" -eq 1 ] && [ "$captive_portal_ok" -eq 1 ]; then
        # وضعیت: اینترنت برقرار است. باید رنگ زرد نمایش داده شود.
        # شاخص ما چراغ سبز است. اگر خاموش باشد، یعنی وضعیت فعلی قرمز است و باید به زرد تغییر کند.
        if [ "$(cat /sys/class/leds/$LED_GREEN/brightness)" -eq 0 ]; then
            log "وضعیت اینترنت: پایدار. تغییر رنگ به زرد."
            set_led_yellow
        fi
    else
        # وضعیت: اینترنت قطع است. باید رنگ قرمز نمایش داده شود.
        # اگر چراغ سبز روشن باشد، یعنی وضعیت فعلی زرد است و باید به قرمز تغییر کند.
        if [ "$(cat /sys/class/leds/$LED_GREEN/brightness)" -ne 0 ]; then
            log "وضعیت اینترنت: قطع. Ping=$ping_ok, DNS=$dns_ok, Portal=$captive_portal_ok. تغییر رنگ به قرمز."
            set_led_red
        fi
    fi

    sleep "$SLEEP_INTERVAL"
done
