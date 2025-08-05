#!/bin/sh

# =================================================================================
# نصب‌کننده خودکار اسکریپت مانیتورینگ LED اینترنت برای OpenWrt
# این اسکریپت تمام مراحل نصب، از جمله دانلود فایل‌ها، تنظیم دسترسی‌ها،
# اعمال تنظیمات سیستمی و فعال‌سازی سرویس را به صورت خودکار انجام می‌دهد.
# =================================================================================

# --- بخش تنظیمات ---
# آدرس ریپازیتوری گیت‌هاب خود را در اینجا وارد کنید.
# ** این بخش را حتما با اطلاعات خودتان ویرایش کنید! **
GITHUB_REPO="Pezhman5252/openwrt-led-script"
BRANCH="main" # یا "master" بسته به نام شاخه اصلی شما

# آدرس کامل فایل‌ها در گیت‌هاب
SCRIPT_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$BRANCH/internet_led_status.sh"
SERVICE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$BRANCH/internet_led"

# مسیرهای نصب فایل‌ها در روتر
SCRIPT_DEST="/usr/bin/internet_led_status.sh"
SERVICE_DEST="/etc/init.d/internet_led"

echo ">>> شروع فرآیند نصب خودکار اسکریپت LED..."

# --- مرحله ۱: دانلود فایل‌ها ---
echo "--> در حال دانلود فایل اسکریپت اصلی..."
if ! wget -O "$SCRIPT_DEST" "$SCRIPT_URL"; then
    echo "!!! خطا در دانلود فایل اسکریپت. از اتصال به اینترنت مطمئن شوید."
    exit 1
fi

echo "--> در حال دانلود فایل سرویس..."
if ! wget -O "$SERVICE_DEST" "$SERVICE_URL"; then
    echo "!!! خطا در دانلود فایل سرویس."
    exit 1
fi

echo ">>> فایل‌ها با موفقیت دانلود شدند."

# --- مرحله ۲: تنظیم دسترسی‌های اجرایی ---
echo "--> تنظیم مجوزهای اجرایی..."
chmod +x "$SCRIPT_DEST"
chmod +x "$SERVICE_DEST"
echo ">>> مجوزها تنظیم شدند."

# --- مرحله ۳: غیرفعال‌سازی کنترل پیش‌فرض LED ها (بسیار مهم) ---
echo "--> اعمال تنظیمات UCI برای کنترل کامل LED ها..."
uci set system.led_green='led'
uci set system.led_green.name='Green'
uci set system.led_green.sysfs='LED0_Green'
uci set system.led_green.trigger='none'

uci set system.led_red='led'
uci set system.led_red.name='Red'
uci set system.led_red.sysfs='LED0_Red'
uci set system.led_red.trigger='none'

uci set system.led_blue='led'
uci set system.led_blue.name='Blue'
uci set system.led_blue.sysfs='LED0_Blue'
uci set system.led_blue.trigger='none'

uci commit system
/etc/init.d/led restart
echo ">>> تنظیمات سیستمی LED با موفقیت اعمال شد."

# --- مرحله ۴: فعال‌سازی و راه‌اندازی سرویس ---
echo "--> فعال‌سازی سرویس برای اجرا پس از هر بار بوت..."
"$SERVICE_DEST" enable

echo "--> راه‌اندازی سرویس برای اولین بار..."
"$SERVICE_DEST" restart

echo ""
echo "****************************************************************"
echo "    نصب با موفقیت به پایان رسید!"
echo "    اسکریپت مانیتورینگ LED اکنون فعال است."
echo "****************************************************************"
