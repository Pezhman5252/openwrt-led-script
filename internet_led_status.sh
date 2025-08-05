#!/bin/sh

# ===================================================================================
# اسکریپت کنترلر LED وضعیت اینترنت - نسخه نهایی طلایی (Gold Standard 6.0)
#
# ویژگی‌ها:
# - بهینه‌سازی شده برای حداقل استفاده از منابع CPU.
# - سرعت پاسخ بالا به تغییرات وضعیت اینترنت.
# - پایداری حداکثری و سازگاری کامل با ساختار OpenWrt.
# - گزارش‌دهی (Logging) دقیق برای عیب‌یابی آسان.
# ===================================================================================

# --- بخش تنظیمات قابل تغییر ---
PING_TARGETS="8.8.8.8 1.1.1.1"
DNS_CHECK_TARGET="google.com"
CAPTIVE_PORTAL_CHECK_URL="http://detectportal.firefox.com/success.txt"
EXPECTED_CAPTIVE_PORTAL_RESPONSE="success"

# شناسه‌های دقیق LED های روتر شما
LED_GREEN="LED0_Green"
LED_RED="LED0_Red"
LED_BLUE="LED0_Blue"

# شدت روشنایی (مقدار بین 1 تا 255)
BRIGHTNESS_LEVEL=50

# فاصله زمانی بین هر بررسی (به ثانیه). مقدار کمتر = سرعت بالاتر، مصرف منابع کمی بیشتر
SLEEP_INTERVAL=10

# --- توابع کنترل LED ---

# تابع تنظیم رنگ زرد (اینترنت وصل)
set_led_yellow() {
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness"
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness"
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_GREEN/brightness"
}

# تابع تنظیم رنگ قرمز (اینترنت قطع)
set_led_red() {
    echo 0 > "/sys/class/leds/$LED_GREEN/brightness"
    echo 0 > "/sys/class/leds/$LED_BLUE/brightness"
    echo "$BRIGHTNESS_LEVEL" > "/sys/class/leds/$LED_RED/brightness"
}

# --- حلقه اصلی برنامه ---
log() {
    logger -t "InternetLED" "$1"
}

log "سرویس کنترلر LED آغاز به کار کرد. نسخه: 6.0 Gold"

# خاموش کردن تمام LED ها در ابتدای کار برای شروعی پاک
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
    if [ "$ping_ok" -eq 1 ]; then # تنها در صورت موفقیت پینگ، دی‌ان‌اس را چک کن
        if nslookup "$DNS_CHECK_TARGET" >/dev/null 2>&1; then dns_ok=1; fi
    fi

    # 3. بررسی Captive Portal
    if [ "$dns_ok" -eq 1 ]; then # تنها در صورت موفقیت پینگ و دی‌ان‌اس، پورتال را چک کن
        response=$(wget -qO- --timeout=5 "$CAPTIVE_PORTAL_CHECK_URL")
        if [ "$?" -eq 0 ] && echo "$response" | grep -q "$EXPECTED_CAPTIVE_PORTAL_RESPONSE"; then
            captive_portal_ok=1
        fi
    fi

    # --- تصمیم‌گیری نهایی ---
    if [ "$captive_portal_ok" -eq 1 ]; then
        # وضعیت: اینترنت کاملاً برقرار است.
        # بهینه‌سازی: تنها در صورتی رنگ را عوض کن که وضعیت فعلی "قرمز" باشد.
        # شاخص وضعیت قرمز، خاموش بودن چراغ سبز است.
        if [ "$(cat /sys/class/leds/$LED_GREEN/brightness)" -eq 0 ]; then
            log "وضعیت اینترنت: پایدار. تغییر رنگ به زرد."
            set_led_yellow
        fi
    else
        # وضعیت: اینترنت قطع است.
        # بهینه‌سازی: تنها در صورتی رنگ را عوض کن که وضعیت فعلی "زرد" باشد.
        # شاخص وضعیت زرد، روشن بودن چراغ سبز است.
        if [ "$(cat /sys/class/leds/$LED_GREEN/brightness)" -ne 0 ]; then
            log "وضعیت اینترنت: قطع! [Ping:$ping_ok, DNS:$dns_ok, Portal:$captive_portal_ok]. تغییر رنگ به قرمز."
            set_led_red
        fi
    fi

    sleep "$SLEEP_INTERVAL"
done
