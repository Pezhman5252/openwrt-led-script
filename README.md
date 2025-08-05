<div align="center">
  <img src="https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/media/logo.png" alt="Project Logo" width="150"/>
  <h1>اسکریپت کنترل هوشمند LED وضعیت اینترنت</h1>
  <p>
    یک اسکریپت بهینه و هوشمند برای روترهای OpenWrt که رنگ LED را بر اساس وضعیت <b>واقعی</b> اتصال اینترنت تغییر می‌دهد.
  </p>
  
  <p>
    <a href="https.github.com/Pezhman5252/openwrt-led-script/stargazers"><img src="https://img.shields.io/github/stars/Pezhman5252/openwrt-led-script?style=for-the-badge&color=ffd000" alt="Stars"></a>
    <a href="https://github.com/Pezhman5252/openwrt-led-script/releases"><img src="https://img.shields.io/github/v/release/Pezhman5252/openwrt-led-script?style=for-the-badge&color=8A2BE2" alt="Release"></a>
    <img src="https://img.shields.io/badge/OpenWrt-21.02%2B-blue.svg?style=for-the-badge&color=00B5E2" alt="OpenWrt Version">
    <a href="https://github.com/Pezhman5252/openwrt-led-script/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Pezhman5252/openwrt-led-script?style=for-the-badge&color=lightgrey" alt="License"></a>
  </p>
</div>

<div dir="rtl">

---

## ✨ ویژگی‌های کلیدی

این اسکریپت فراتر از یک `ping` ساده عمل کرده و با بررسی چند لایه، اطمینان حاصل می‌کند که اینترنت بدون هیچ مانعی در دسترس است.

- **🚀 نصب کاملاً خودکار:** با یک دستور ساده، تمام پیش‌نیازها (`wget-ssl` و `ca-bundle`) به صورت هوشمند نصب و سرویس فعال می‌شود.
- **🧠 بررسی چند لایه و هوشمند:**
  1.  **Ping:** بررسی اتصال پایه به سرورهای پایدار جهانی (مانند `8.8.8.8`).
  2.  **DNS:** اطمینان از عملکرد صحیح DNS برای ترجمه دامنه‌ها.
  3.  **Captive Portal:** تشخیص صفحات لاگین (مخصوص هتل‌ها، فرودگاه‌ها و...) برای دسترسی مستقیم.
- **💡 بهینه‌سازی شده برای روتر:** حداقل استفاده از منابع CPU و جلوگیری از نوشتن‌های غیرضروری روی حافظه فلش برای تضمین طول عمر دستگاه.
- **🛡️ پایداری حداکثری:** استفاده از `procd` (سیستم مدیریت سرویس OpenWrt) برای راه‌اندازی مجدد خودکار در صورت بروز خطا.
- **⚙️ پیکربندی آسان:** تمام تنظیمات اصلی در ابتدای فایل اسکریپت به صورت خوانا و قابل تغییر قرار گرفته‌اند.
- **📝 گزارش‌دهی دقیق:** ثبت تمام رویدادهای مهم در لاگ سیستم (`logread`) برای عیب‌یابی آسان.

---

## 📥 نصب سریع و خودکار (دستور یک خطی)

برای نصب، از طریق SSH به ترمینال روتر خود متصل شوید و دستور زیر را به صورت کامل کپی و اجرا کنید.

```sh
wget --no-check-certificate https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/install.sh -O /tmp/install.sh && sh /tmp/install.sh
```
> **این دستور چه می‌کند؟**
> اسکریپت نصب را دانلود کرده، پیش‌نیازهای اتصال امن را نصب می‌کند و سپس فایل‌های اصلی پروژه را به صورت امن دریافت و سرویس را راه‌اندازی می‌کند.

---

## 🔧 پیکربندی پس از نصب (بسیار مهم)

نام LED ها در مدل‌های مختلف روتر متفاوت است. این مرحله برای عملکرد صحیح اسکریپت ضروری است.

**۱. پیدا کردن نام LED ها:**
با دستور زیر، لیست LED های موجود در روتر خود را مشاهده کنید:
```sh
ls /sys/class/leds/
```
خروجی چیزی شبیه به `gl-ar300m:green:wan` یا `tp-link:blue:qss` خواهد بود. نام‌های مربوط به LED چندرنگ دستگاه خود را پیدا کنید.

**۲. ویرایش فایل پیکربندی:**
فایل اسکریپت اصلی را با یک ویرایشگر متن مانند `vi` یا `nano` باز کنید:
```sh
vi /usr/bin/internet_led_status.sh
```
> *نکته: در ویرایشگر `vi`، کلید `i` را برای ورود به حالت ویرایش، و پس از تغییرات، کلید `Esc` را زده، سپس `:wq` را تایپ و `Enter` را برای ذخیره فشار دهید.*

**۳. اعمال تغییرات:**
در بخش تنظیمات (`--- بخش تنظیمات قابل تغییر ---`)، مقادیر متغیرهای `LED_GREEN`، `LED_RED` و `LED_BLUE` را با نام‌هایی که در مرحله اول پیدا کردید، جایگزین نمایید.

**۴. راه‌اندازی مجدد سرویس:**
پس از ذخیره تغییرات، سرویس را با دستور زیر مجدداً راه‌اندازی کنید:```sh
/etc/init.d/internet_led restart
```

---

## ⚙️ دستورات مدیریتی سرویس

برای مدیریت سرویس از دستورات استاندارد OpenWrt استفاده کنید:

| عملکرد                  | دستور                                  |
| ----------------------- | -------------------------------------- |
| **شروع سرویس**          | `/etc/init.d/internet_led start`       |
| **توقف سرویس**           | `/etc/init.d/internet_led stop`        |
| **راه‌اندازی مجدد**      | `/etc/init.d/internet_led restart`     |
| **فعال‌سازی در بوت**      | `/etc/init.d/internet_led enable`      |
| **غیرفعال‌سازی در بوت**   | `/etc/init.d/internet_led disable`     |
| **مشاهده لاگ‌ها**         | `logread -f -e "InternetLED"`          |

---

## 🗑️ حذف کامل

برای حذف کامل اسکریپت و سرویس از روی روتر، دستورات زیر را به ترتیب در ترمینال اجرا کنید.

```sh
# ۱. توقف و غیرفعال‌سازی سرویس
/etc/init.d/internet_led stop
/etc/init.d/internet_led disable

# ۲. حذف فایل‌های پروژه
rm /etc/init.d/internet_led
rm /usr/bin/internet_led_status.sh

echo "اسکریپت کنترلر LED با موفقیت حذف شد."
```

</div>
