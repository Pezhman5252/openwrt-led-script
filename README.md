<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>اسکریپت کنترل هوشمند LED وضعیت اینترنت برای OpenWrt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #2b6cb0;
            --success: #38a169;
            --danger: #e53e3e;
            --warning: #dd6b20;
            --info: #3182ce;
            --dark: #2d3748;
            --light: #f7fafc;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.8;
            color: #2d3748;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 2rem;
            background-color: white;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border-radius: 0.5rem;
            margin-top: 2rem;
            margin-bottom: 2rem;
        }
        
        h1, h2, h3, h4 {
            color: var(--dark);
            margin-top: 1.5em;
            margin-bottom: 0.5em;
            font-weight: 600;
        }
        
        h1 {
            font-size: 2.2rem;
            border-bottom: 2px solid var(--primary);
            padding-bottom: 0.5rem;
            color: var(--primary);
        }
        
        h2 {
            font-size: 1.8rem;
            border-right: 4px solid var(--primary);
            padding-right: 0.8rem;
        }
        
        h3 {
            font-size: 1.4rem;
        }
        
        a {
            color: var(--primary);
            text-decoration: none;
            transition: color 0.2s;
        }
        
        a:hover {
            color: var(--info);
            text-decoration: underline;
        }
        
        code {
            font-family: 'Courier New', Courier, monospace;
            background-color: #edf2f7;
            padding: 0.2rem 0.4rem;
            border-radius: 0.25rem;
            color: #c53030;
        }
        
        pre {
            background-color: #1a202c;
            color: #e2e8f0;
            padding: 1rem;
            border-radius: 0.5rem;
            overflow-x: auto;
            direction: ltr;
            text-align: left;
        }
        
        pre code {
            background-color: transparent;
            color: inherit;
            padding: 0;
        }
        
        .badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.875rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }
        
        .badge-primary {
            background-color: var(--primary);
            color: white;
        }
        
        .badge-success {
            background-color: var(--success);
            color: white;
        }
        
        .badge-danger {
            background-color: var(--danger);
            color: white;
        }
        
        .badge-warning {
            background-color: var(--warning);
            color: white;
        }
        
        .feature-box {
            background-color: #f0f9ff;
            border-left: 4px solid var(--primary);
            padding: 1rem;
            margin: 1rem 0;
            border-radius: 0 0.5rem 0.5rem 0;
        }
        
        .feature-icon {
            font-size: 1.5rem;
            margin-left: 0.5rem;
            color: var(--primary);
            vertical-align: middle;
        }
        
        .command-box {
            background-color: #f0fff4;
            border: 1px solid #c6f6d5;
            border-radius: 0.5rem;
            padding: 1rem;
            margin: 1rem 0;
            position: relative;
        }
        
        .command-box:before {
            content: "دستور نصب";
            position: absolute;
            top: -10px;
            right: 15px;
            background-color: #f0fff4;
            padding: 0 0.5rem;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--success);
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            margin: 1rem 0;
        }
        
        .table th, .table td {
            padding: 0.75rem;
            text-align: right;
            border: 1px solid #e2e8f0;
        }
        
        .table th {
            background-color: #edf2f7;
            font-weight: 600;
        }
        
        .table tr:nth-child(even) {
            background-color: #f8fafc;
        }
        
        .table tr:hover {
            background-color: #ebf8ff;
        }
        
        .note {
            background-color: #fffaf0;
            border-left: 4px solid var(--warning);
            padding: 1rem;
            margin: 1rem 0;
            border-radius: 0 0.5rem 0.5rem 0;
        }
        
        .note-title {
            font-weight: 600;
            color: var(--warning);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
        }
        
        .note-title i {
            margin-left: 0.5rem;
        }
        
        .steps {
            counter-reset: step-counter;
            padding-right: 0;
        }
        
        .step {
            position: relative;
            padding-right: 2.5rem;
            margin-bottom: 1.5rem;
        }
        
        .step:before {
            counter-increment: step-counter;
            content: counter(step-counter);
            position: absolute;
            right: 0;
            top: 0;
            width: 2rem;
            height: 2rem;
            background-color: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
                margin: 1rem;
            }
            
            h1 {
                font-size: 1.8rem;
            }
            
            h2 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>
            اسکریپت کنترل هوشمند LED وضعیت اینترنت برای OpenWrt
            <span class="badge badge-primary">OpenWrt</span>
        </h1>
        
        <p>این پروژه شامل یک اسکریپت هوشمند و بهینه برای روترهای مجهز به سیستم‌عامل OpenWrt است که رنگ LED دستگاه را بر اساس وضعیت <strong>واقعی و کامل</strong> اتصال به اینترنت تغییر می‌دهد. این اسکریپت فراتر از یک <code>ping</code> ساده عمل کرده و با بررسی چند لایه، اطمینان حاصل می‌کند که اینترنت بدون هیچ مانعی در دسترس است.</p>
        
        <div class="feature-box">
            <h2>
                <i class="fas fa-star feature-icon"></i>
                ویژگی‌های کلیدی
            </h2>
            
            <ul>
                <li><strong>نصب کاملاً خودکار:</strong> اسکریپت نصب به صورت هوشمند پیش‌نیازهای خود (<code>wget-ssl</code> و <code>ca-bundle</code>) را بررسی و در صورت نیاز نصب می‌کند. کاربر فقط یک دستور را اجرا می‌کند.</li>
                <li><strong>بررسی چند لایه و هوشمند:</strong> وضعیت اینترنت به صورت آبشاری در سه لایه بررسی می‌شود تا از تشخیص اشتباه جلوگیری شود:
                    <ol>
                        <li><strong>Ping:</strong> بررسی اتصال پایه به سرورهای پایدار جهانی (مانند 8.8.8.8 و 1.1.1.1).</li>
                        <li><strong>DNS:</strong> حصول اطمینان از عملکرد صحیح DNS برای ترجمه نام دامنه‌ها.</li>
                        <li><strong>Captive Portal:</strong> تشخیص صفحات لاگین (مربوط به هتل‌ها، فرودگاه‌ها و ...) و اطمینان از دسترسی مستقیم به اینترنت.</li>
                    </ol>
                </li>
                <li><strong>بهینه‌سازی شده برای روتر:</strong> با حداقل استفاده از منابع پردازشی (CPU) و جلوگیری از نوشتن‌های غیرضروری روی حافظه فلش (Flash Memory) طراحی شده تا عملکرد و طول عمر دستگاه را تضمین کند.</li>
                <li><strong>پایداری حداکثری:</strong> با بهره‌گیری از سیستم مدیریت سرویس استاندارد OpenWrt یعنی <code>procd</code>، در صورت بروز هرگونه خطا، سرویس به صورت خودکار مجدداً راه‌اندازی می‌شود.</li>
                <li><strong>پیکربندی آسان:</strong> تمام تنظیمات اصلی مانند آدرس‌های هدف، نام LED ها و شدت روشنایی در ابتدای فایل اسکریپت اصلی به صورت خوانا قرار گرفته‌اند.</li>
                <li><strong>گزارش‌دهی دقیق:</strong> تمام رویدادهای مهم (اتصال، قطعی و دلایل آن) در لاگ سیستم OpenWrt ثبت می‌شوند که عیب‌یابی را بسیار آسان می‌کند.</li>
            </ul>
        </div>
        
        <h2>
            <i class="fas fa-rocket"></i>
            نصب سریع و خودکار (دستور یک خطی)
        </h2>
        
        <div class="command-box">
            <pre><code>wget --no-check-certificate https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/install.sh -O /tmp/install.sh && sh /tmp/install.sh</code></pre>
        </div>
        
        <p><strong>این دستور چه کاری انجام می‌دهد؟</strong><br>
        این دستور ابتدا اسکریپت نصب را (با نادیده گرفتن موقت گواهی SSL برای سازگاری با سیستم‌های خام) دانلود می‌کند. سپس، اسکریپت نصب اجرا شده و در اولین قدم، پکیج‌های لازم برای اتصال امن اینترنتی را نصب می‌کند و پس از آن، فایل‌های اصلی پروژه را به صورت امن دانلود و سرویس را راه‌اندازی می‌کند.</p>
        
        <div class="note">
            <div class="note-title">
                <i class="fas fa-lightbulb"></i>
                نکته مهم
            </div>
            <p>برای اجرای این دستور باید از طریق SSH به روتر متصل شده باشید و دسترسی root داشته باشید.</p>
        </div>
        
        <h2>
            <i class="fas fa-cog"></i>
            پیکربندی پس از نصب (بسیار مهم)
        </h2>
        
        <p>مهم‌ترین قدم پس از نصب، تنظیم شناسه‌های LED مخصوص مدل روتر شماست، زیرا این نام‌ها در دستگاه‌های مختلف متفاوت است.</p>
        
        <div class="steps">
            <div class="step">
                <h3>پیدا کردن نام LED ها</h3>
                <p>ابتدا با دستور زیر، لیست LED های موجود در روتر خود را مشاهده کنید:</p>
                <pre><code>ls /sys/class/leds/</code></pre>
                <p>خروجی این دستور، نام‌هایی مانند <code>gl-ar300m:green:wan</code>، <code>tp-link:blue:qss</code> یا <code>your_router_model:green:internet</code> خواهد بود. نام‌های مربوط به LED چندرنگ اصلی دستگاه خود را که می‌خواهید کنترل کنید، پیدا کنید.</p>
            </div>
            
            <div class="step">
                <h3>ویرایش فایل پیکربندی</h3>
                <p>فایل اسکریپت اصلی را با یک ویرایشگر متن مانند <code>vi</code> یا <code>nano</code> باز کنید:</p>
                <pre><code>vi /usr/bin/internet_led_status.sh</code></pre>
                <div class="note">
                    <div class="note-title">
                        <i class="fas fa-info-circle"></i>
                        نکته
                    </div>
                    <p>در ویرایشگر <code>vi</code>، کلید <code>i</code> را برای ورود به حالت ویرایش فشار دهید. پس از انجام تغییرات، کلید <code>Esc</code> را زده، سپس <code>:wq</code> را تایپ و <code>Enter</code> را فشار دهید تا فایل ذخیره و بسته شود.</p>
                </div>
            </div>
            
            <div class="step">
                <h3>اعمال تغییرات</h3>
                <p>در بخش تنظیمات (<code>--- بخش تنظیمات قابل تغییر ---</code>)، مقادیر متغیرهای <code>LED_GREEN</code>، <code>LED_RED</code> و <code>LED_BLUE</code> را با نام‌های دقیقی که در مرحله اول پیدا کردید، جایگزین نمایید.</p>
            </div>
            
            <div class="step">
                <h3>راه‌اندازی مجدد سرویس</h3>
                <p>پس از ذخیره تغییرات، سرویس را با دستور زیر مجدداً راه‌اندازی کنید تا تنظیمات جدید اعمال شوند:</p>
                <pre><code>/etc/init.d/internet_led restart</code></pre>
            </div>
        </div>
        
        <h2>
            <i class="fas fa-terminal"></i>
            دستورات مدیریتی سرویس
        </h2>
        
        <p>شما می‌توانید سرویس را به راحتی از طریق ترمینال مدیریت کنید:</p>
        
        <table class="table">
            <thead>
                <tr>
                    <th>عملکرد</th>
                    <th>دستور</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>شروع سرویس</strong></td>
                    <td><code>/etc/init.d/internet_led start</code></td>
                </tr>
                <tr>
                    <td><strong>توقف سرویس</strong></td>
                    <td><code>/etc/init.d/internet_led stop</code></td>
                </tr>
                <tr>
                    <td><strong>راه‌اندازی مجدد</strong></td>
                    <td><code>/etc/init.d/internet_led restart</code></td>
                </tr>
                <tr>
                    <td><strong>فعال‌سازی در بوت</strong></td>
                    <td><code>/etc/init.d/internet_led enable</code></td>
                </tr>
                <tr>
                    <td><strong>غیرفعال‌سازی در بوت</strong></td>
                    <td><code>/etc/init.d/internet_led disable</code></td>
                </tr>
                <tr>
                    <td><strong>مشاهده لاگ‌ها</strong></td>
                    <td><code>logread -f -e "InternetLED"</code></td>
                </tr>
            </tbody>
        </table>
        
        <h2>
            <i class="fas fa-trash-alt"></i>
            حذف کامل
        </h2>
        
        <p>برای حذف کامل اسکریپت و سرویس از روی روتر، دستورات زیر را به ترتیب در ترمینال اجرا کنید. این کار تمام فایل‌های مربوطه را پاک کرده و سرویس را غیرفعال می‌کند.</p>
        
        <pre><code># ۱. ابتدا سرویس را متوقف و غیرفعال کنید
/etc/init.d/internet_led stop
/etc/init.d/internet_led disable

# ۲. سپس فایل‌های مربوطه را حذف کنید
rm /etc/init.d/internet_led
rm /usr/bin/internet_led_status.sh

echo "اسکریپت کنترلر LED با موفقیت حذف شد."</code></pre>
    </div>
</body>
</html>
