# miro

**English | فارسی**

---

## ENGLISH

**miro** is an automatic, smart script to optimize Ubuntu APT mirrors. It helps you always have the fastest and healthiest repositories, without manual configs or worrying about network/internet issues or broken source lists.

### Features

- **Automatic Ubuntu version/codename detection**
- **Tests all mirrors (domestic & global) for reachability and speed**
- **Safely backs up and restores all APT sources and keys**
- **Refreshes APT keys (without deleting any)**
- **Professional, user-friendly menu (or direct CLI usage)**
- **Never leaves your system with a broken or empty sources list**
- **Works with any network (local, global, VPN, etc.)**

---

### Installation & Usage

1. **Save and install the script:**
   ```bash
   wget https://raw.githubusercontent.com/Shellgate/apt-servers-optimal/main/miro.sh -O miro.sh
   chmod +x miro.sh
   sudo mv miro.sh /usr/local/bin/miro
   ```

2. **Run with menu:**
   ```bash
   sudo miro
   ```

3. **Direct usage:**
   - Optimize sources:
     ```bash
     sudo miro 1
     ```
   - Restore last backup:
     ```bash
     sudo miro 2
     ```
   - Show backup list:
     ```bash
     sudo miro 3
     ```
   - Quit:
     ```bash
     sudo miro q
     ```

---

### Menu Options

| Number | Action                              |
|--------|-------------------------------------|
| 1      | Optimize and select fastest mirrors |
| 2      | Restore last backup                 |
| 3      | Show backup list and info           |
| q      | Quit                                |

---

### How does it work?

- Detects your Ubuntu codename automatically.
- Backs up all your APT sources and keys before any change.
- Finds the fastest, healthiest mirrors by ping, HTTP, and download speed.
- Safely rewrites your sources.list.
- Refreshes (never deletes) APT keys.
- Keeps all backups for easy restore.

---

### Security & Pro Tips

- **Always run as root (sudo).**
- You may delete or archive old backups in `/etc/apt/`.
- If the network is down, no changes are made and you can safely restore from backup.

---

### Contributing

Have a suggestion, bug, or feature request?  
Open an issue or send a PR!  
The script is well-commented and follows best bash scripting practices.

---

### License

MIT License  
Free and open source.

---

<div align="center">
Always have the fastest, healthiest Ubuntu mirrors, painlessly! 🚀
</div>

---

## فارسی

**miro** یک اسکریپت خودکار و هوشمند برای بهینه‌سازی منابع نرم‌افزاری (APT mirrors) اوبونتو است که به شما این امکان را می‌دهد همیشه سریع‌ترین و سالم‌ترین مخازن را داشته باشید، بدون نیاز به تنظیمات دستی یا نگرانی بابت قطعی اینترنت یا خراب شدن سورس‌ها.

### ویژگی‌ها

- **تشخیص خودکار نسخه اوبونتو**
- **تست سلامت و سرعت همه میرورها (داخلی و خارجی)**
- **ساخت و بازگردانی امن بکاپ از تمام منابع و کلیدها**
- **به‌روزرسانی کلیدهای APT بدون حذف**
- **منوی حرفه‌ای و کاربرپسند (یا اجرای مستقیم از خط فرمان)**
- **هرگز فایل مخازن را خراب یا خالی نمی‌گذارد**
- **سازگار با هر نوع شبکه (داخلی، خارجی، VPN و...)**

---

### نصب و اجرا

1. **دریافت و نصب اسکریپت:**
   ```bash
   wget https://raw.githubusercontent.com/Shellgate/apt-servers-optimal/main/miro.sh -O miro.sh
   chmod +x miro.sh
   sudo mv miro.sh /usr/local/bin/miro
   ```

2. **اجرا با منو:**
   ```bash
   sudo miro
   ```

3. **اجرا به صورت مستقیم:**
   - بهینه‌سازی سریع:
     ```bash
     sudo miro 1
     ```
   - بازگردانی آخرین بکاپ:
     ```bash
     sudo miro 2
     ```
   - نمایش لیست بکاپ‌ها:
     ```bash
     sudo miro 3
     ```
   - خروج:
     ```bash
     sudo miro q
     ```

---

### گزینه‌های برنامه

| شماره | عملکرد                                 |
|-------|----------------------------------------|
| 1     | بهینه‌سازی و انتخاب سریع‌ترین میرورها |
| 2     | بازگردانی آخرین بکاپ                  |
| 3     | نمایش لیست و اطلاعات بکاپ‌ها           |
| q     | خروج از برنامه                        |

---

### چطور کار می‌کند؟

- ابتدا نسخه اوبونتو شما را شناسایی می‌کند.
- از منابع و کلیدهای فعلی بکاپ می‌گیرد.
- سریع‌ترین میرورها را با تست پینگ، HTTP و سرعت دانلود پیدا می‌کند.
- فایل سورس را بازنویسی و مرتب می‌کند.
- کلیدها را فقط به‌روز می‌کند (هیچ کلیدی حذف نمی‌شود).
- همیشه بکاپ‌ها را نگه می‌دارد و به راحتی قابل بازگردانی هستند.

---

### نکات امنیتی و حرفه‌ای

- فقط با دسترسی root (یا sudo) اجرا شود.
- بکاپ‌های قدیمی در مسیر `/etc/apt/` قابل حذف یا آرشیو هستند.
- اگر شبکه قطع باشد، سورس خراب یا خالی نمی‌شود و از بکاپ قابل بازگردانی است.

---

### مشارکت و توسعه

پیشنهاد، باگ یا درخواست جدید دارید؟  
ایشیو بزنید یا Pull Request ارسال کنید!  
کد تمیز و کامنت‌گذاری شده و مطابق اصول bash scripting نوشته شده است.

---

### مجوز

MIT License  
این پروژه کاملاً بازمتن و رایگان است.

---

<div align="center">
  با خیال راحت و بدون دردسر، همیشه سریع‌ترین و سالم‌ترین مخازن اوبونتو را داشته باشید! 🚀
</div>
