```markdown
<div align="center">

![Image](https://github.com/user-attachments/assets/098610cf-0a2b-4b0e-8283-974a858406a0)

**Advanced Ubuntu APT Mirror Optimizer**  
ابزار حرفه‌ای و هوشمند بهینه‌سازی مخازن اوبونتو  
[English](#english) | [فارسی](#فارسی)

</div>

---

## English

### 🚀 What is miro?

**miro** is an advanced, smart, and safe Bash script for automatically optimizing Ubuntu APT sources.
It tests all known (Iranian & worldwide) Ubuntu mirrors for speed and availability, makes a full backup of your sources and keys, and updates your `/etc/apt/sources.list` with the fastest, healthiest repositories – all with a beautiful, colorized, user-friendly interface!

---

### ✨ Features

- **Automatic Ubuntu version/codename detection**
- **Tests all known mirrors (Iranian & global) for ping, HTTP, and download speed**
- **Sorts and selects the top fastest and healthy mirrors**
- **Full backup and easy restore for sources and APT keys**
- **Clean, colorized, user-friendly menu and CLI**
- **Never leaves your sources.list empty or broken**
- **Refreshes APT keys (never deletes any key)**
- **Safe for all networks (domestic, international, VPN, etc.)**
- **Run by name or number – no need to type `miro` again**
- **Professional ASCII logo and status messages**
- **Multilingual: Persian and English in the same script and documentation**
- **Full repair and troubleshooting menu**
- **Full uninstall and revert-to-default option**

---

### 🛠️ Installation

```bash
wget https://raw.githubusercontent.com/Shellgate/apt-servers-optimal/main/miro.sh -O miro.sh
chmod +x miro.sh
sudo mv miro.sh /usr/local/bin/miro
```

---

### 🚦 Usage

You can run the script directly by its filename or by `miro` after copying/moving to `/usr/local/bin/miro`:

```bash
sudo ./miro.sh
# or simply
sudo miro
```

Or run a specific action directly:

| Command            | Action                                  |
|--------------------|-----------------------------------------|
| `sudo miro 1`      | Optimize and select fastest mirrors     |
| `sudo miro 2`      | Restore last backup                     |
| `sudo miro 3`      | Show backup list/info                   |
| `sudo miro 4`      | Repair & Troubleshoot                   |
| `sudo miro 5`      | Full Uninstall & revert to Ubuntu default|
| `sudo miro 6`      | Exit                                    |

---

### 🎨 Menu Example

```text
 __  __ _       _       
|  \/  (_)_ __ (_) ___  
| |\/| | | '_ \| |/ _ \ 
| |  | | | | | | | (_) |
|_|  |_|_|_| |_|_|\___/ 
APT Servers Optimal by Shellgate

============== MIRO MENU ==============
1) Optimize Ubuntu mirrors (recommended)
2) Restore last backup
3) Show backup info
4) Repair & Troubleshoot
5) Full Uninstall & revert to Ubuntu default
6) Exit
=======================================
Select an option [1/2/3/4/5/6]:
```

---

### 🧠 How does it work?

- Detects your Ubuntu codename automatically.
- Backs up all your APT sources and keyrings before any change.
- Tests all mirrors with ping, HTTP, and a speed test, then sorts and selects the top 3.
- Writes a clean, duplicate-free, safe `/etc/apt/sources.list`.
- Only refreshes (never deletes) APT keys.
- Keeps all backups for easy restore at any time.
- Can repair or restore broken sources.
- Can uninstall all changes and revert to Ubuntu defaults.

---

### 💡 Tips & Security

- **Always run as root (`sudo`).**
- Backups are stored in `/etc/apt/` (as `sources-cleanup-backup-*`). You can delete old backups if needed.
- If the network is down or all mirrors fail, nothing is changed and you can always restore a backup.
- Works on all Ubuntu flavors and derivatives.

---

### 🤝 Contribution

Have suggestions, bug reports, or feature requests?  
Open an [issue](https://github.com/Shellgate/apt-servers-optimal/issues) or send a [pull request](https://github.com/Shellgate/apt-servers-optimal/pulls)!  
Script is well-commented and follows best Bash scripting practices.

---

### 📄 License

MIT License  
Free and Open Source.

---

<div align="center">
Always have the fastest, healthiest Ubuntu mirrors — painlessly! 🚀
</div>

---

## فارسی

### 🚀 miro چیست؟

**miro** یک اسکریپت پیشرفته، هوشمند و امن برای بهینه‌سازی خودکار منابع (APT) اوبونتو است.
این ابزار همه میرورهای ایرانی و جهانی را از نظر سرعت و سلامت تست می‌کند، از سورس و کلیدهای شما بکاپ کامل می‌گیرد و با رابط کاربری رنگی و زیبا، سریع‌ترین و سالم‌ترین مخازن را جایگزین می‌کند.

---

### ✨ ویژگی‌ها

- **تشخیص خودکار نسخه و کدنام اوبونتو**
- **تست همه میرورها (داخلی و خارجی) با پینگ، HTTP و سرعت دانلود**
- **انتخاب خودکار سریع‌ترین و سالم‌ترین مخازن**
- **بکاپ کامل و بازگردانی آسان برای سورس‌ها و کلیدها**
- **منوی رنگی و حرفه‌ای (هم با نام فایل هم با دستور miro)**
- **هرگز sources.list را خالی یا خراب نمی‌کند**
- **فقط کلیدها را به‌روز می‌کند (حذفی صورت نمی‌گیرد)**
- **سازگار با هر نوع شبکه (داخلی، خارجی، VPN و...)**
- **اجرا با نام فایل یا با دستور miro**
- **لوگوی حرفه‌ای و پیام‌های وضعیت رنگی**
- **فارسی و انگلیسی در یک اسکریپت و مستندات**
- **منوی بازسازی و رفع اشکال**
- **حذف کامل و بازگردانی به حالت اولیه اوبونتو**

---

### 🛠️ نصب

```bash
wget https://raw.githubusercontent.com/Shellgate/apt-servers-optimal/main/miro.sh -O miro.sh
chmod +x miro.sh
sudo mv miro.sh /usr/local/bin/miro
```

---

### 🚦 استفاده

مستقیم با نام فایل (در همان دایرکتوری):

```bash
sudo ./miro.sh
```

یا با نام `miro` (پس از کپی یا انتقال اسکریپت):

```bash
sudo miro
```

همچنین می‌توانید مستقیماً با شماره اجرا کنید:

| دستور               | عملکرد                                  |
|---------------------|-----------------------------------------|
| `sudo miro 1`       | بهینه‌سازی و انتخاب سریع‌ترین میرورها  |
| `sudo miro 2`       | بازگردانی آخرین بکاپ                   |
| `sudo miro 3`       | نمایش لیست و اطلاعات بکاپ‌ها            |
| `sudo miro 4`       | بازسازی و رفع اشکال                     |
| `sudo miro 5`       | حذف کامل و بازگردانی به تنظیمات اولیه  |
| `sudo miro 6`       | خروج                                    |

---

### 🎨 نمونه منو

```text
 __  __ _       _       
|  \/  (_)_ __ (_) ___  
| |\/| | | '_ \| |/ _ \ 
| |  | | | | | | | (_) |
|_|  |_|_|_| |_|_|\___/ 
APT Servers Optimal by Shellgate

============== MIRO MENU ==============
1) بهینه‌سازی و انتخاب سریع‌ترین میرورها
2) بازگردانی آخرین بکاپ
3) نمایش اطلاعات بکاپ‌ها
4) بازسازی و رفع اشکال
5) حذف کامل و بازگردانی تنظیمات اولیه
6) خروج
=======================================
یک گزینه را وارد کنید [1/2/3/4/5/6]:
```

---

### 🧠 چطور کار می‌کند؟

- نسخه و کدنام اوبونتو را خودکار تشخیص می‌دهد.
- قبل از هر تغییر، بکاپ کامل از سورس‌ها و کلیدها می‌گیرد.
- تمامی میرورها را تست و سریع‌ترین‌ها را انتخاب می‌کند.
- یک فایل sources.list تمیز و بدون تکرار می‌سازد و جایگزین می‌کند.
- کلیدهای APT فقط به‌روز می‌شوند و حذف نمی‌شوند.
- بکاپ‌ها همیشه قابل بازگردانی هستند.
- امکان بازسازی یا ترمیم خودکار وجود دارد.
- امکان حذف کامل و بازگردانی به حالت اولیه اوبونتو وجود دارد.

---

### 💡 نکات امنیتی و حرفه‌ای

- **همیشه با sudo اجرا کنید.**
- بکاپ‌ها در مسیر `/etc/apt/` با نام `sources-cleanup-backup-*` ذخیره می‌شوند و قابل حذف یا آرشیو هستند.
- اگر شبکه قطع باشد یا همه میرورها غیرفعال باشند هیچ تغییری اعمال نمی‌شود و می‌توانید از بکاپ استفاده کنید.
- روی تمام نسخه‌ها و مشتقات اوبونتو قابل استفاده است.

---

### 🤝 مشارکت

برای پیشنهاد، گزارش باگ یا افزودن قابلیت جدید، [ایشیو](https://github.com/Shellgate/apt-servers-optimal/issues) یا [پول‌ریکوئست](https://github.com/Shellgate/apt-servers-optimal/pulls) ثبت کنید!
کد تمیز و کامنت‌گذاری شده است و مطابق استانداردهای bash scripting توسعه یافته.

---

### 📄 مجوز

MIT License  
کاملاً رایگان و متن‌باز.

---

<div align="center">
با خیال راحت، همیشه سریع‌ترین و سالم‌ترین مخازن اوبونتو را داشته باشید! 🚀
</div>
```
