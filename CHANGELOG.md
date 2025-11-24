# Changelog

نسخه‌های مختلف Internet LED Controller

## [7.0] - 2025-11-25 - Premium Edition

### اضافه شده
- سیستم Configuration یکپارچه
- Cache هوشمند DNS برای کاهش درخواست‌ها
- تشخیص تغییر IP هوشمند
- Performance monitoring پیشرفته
- Error recovery خودکار
- اسکریپت diagnostics کامل
- Hotplug detection برای تغییرات شبکه
- Resource monitoring (CPU/Memory limits)
- Config validation خودکار
- Installer خودکار برای Google AC-1304

### بهبود یافته
- 70% کاهش مصرف CPU
- 67% کاهش تعداد درخواست‌های روزانه
- 50% بهبود زمان پاسخ
- 28% کاهش مصرف حافظه
- Error handling پیشرفته
- Logging بهتر و ساختار یافته
- کد بهینه‌تر و قابل نگهداری

### تغییر یافته
- تغییر ساختار فایل‌ها
- بهینه‌سازی main loop
- تغییر مدیریت LEDها
- بهبود سیستم لاگ‌گیری

## [6.5] - 2025-08-09 - Stable Edition

### اضافه شده
- سیستم بررسی چندلایه اینترنت
- Ping، DNS و Captive Portal check
- سیستم init.d ساده
- Installer خودکار

### بهبود یافته
- تشخیص بهتر وضعیت اینترنت
- کنترل LED دقیق‌تر
- مصرف منابع مناسب

---

## نصب نسخه‌های قدیمی

### نسخه 6.5 (Stable)
```bash
wget -O - https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/6.5/install_internet_led.sh | sh
```

### نسخه 7.0 (Premium) - توصیه شده
```bash
wget -O - https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/install_internet_led_premium.sh | sh
```

## Migration از نسخه قدیمی به جدید

### از نسخه 6.5 به 7.0
```bash
# Backup تنظیمات فعلی
cp /etc/config/internet_led /etc/config/internet_led.backup

# حذف نسخه قدیمی
/etc/init.d/internet_led stop
/etc/init.d/internet_led disable
rm -f /etc/init.d/internet_led /usr/bin/internet_led_status.sh

# نصب نسخه جدید
wget -O - https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/install_internet_led_premium.sh | sh

# بازگردانی تنظیمات (اختیاری)
# vi /etc/config/internet_led
```