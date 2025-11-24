# 🔧 Internet LED Controller - Installation Guide

## 🎯 Quick Start

### Recommended Installation (All-in-One):
```bash
wget -O install.sh https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/all_in_one_installer.sh
chmod +x install.sh
./install.sh
```

## 📋 Installation Options

### Option 1: All-in-One Installer ✅ (RECOMMENDED)

**File**: `all_in_one_installer.sh`
- Contains ALL code in single file
- No external dependencies
- Includes all menu options
- Works immediately

**Benefits**:
- ✅ One download, everything works
- ✅ No "file not found" errors
- ✅ Complete functionality included
- ✅ Professional user experience

### Option 2: Original Quick Setup

**File**: `quick_setup_fixed.sh`
- Enhanced version of original
- Auto-downloads missing files
- Maintains original menu structure

**Requirements**:
- Complete package download
- All script files in same directory

## 💡 What It Does

The Internet LED Controller:
- **Monitors internet connectivity** every 10 seconds
- **Shows Yellow LED** when connected
- **Shows Red LED** when disconnected
- **Logs all status changes** to `/tmp/internet_led.log`
- **Starts automatically** on router boot

## 🔧 Menu Options

After installation, choose from:

1️⃣ **Automatic Setup** - Install with default settings
2️⃣ **Manual LED Configuration** - Customize LED paths for your router
3️⃣ **Test Current Installation** - Verify everything works correctly
4️⃣ **Uninstall Completely** - Remove all components
5️⃣ **Run Diagnostics** - Troubleshoot any issues
6️⃣ **Exit** - Close installer

## 🚀 Installation Process

### Step 1: Download
```bash
wget -O install.sh https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/all_in_one_installer.sh
```

### Step 2: Make Executable
```bash
chmod +x install.sh
```

### Step 3: Run Installer
```bash
./install.sh
```

### Step 4: Follow Menu Prompts
- Choose Option 1 for automatic setup
- Or choose Option 2 for manual LED configuration
- Test with Option 3

## 🔍 Troubleshooting

### Problem: "install_simple.sh not found"
**Solution**: Use the All-in-One installer instead:
```bash
wget -O install.sh https://raw.githubusercontent.com/Pezhman5252/openwrt-led-script/main/all_in_one_installer.sh
```

### Problem: "Permission denied"
**Solution**: 
```bash
chmod +x install.sh
```

### Problem: LED doesn't work
**Solution**: 
1. Run Option 2 (Manual LED Configuration)
2. Run Option 5 (Run Diagnostics) to check LED paths
3. Verify your router model supports LED control

### Problem: Service doesn't start
**Solution**:
```bash
# Check service status
/etc/init.d/internet_led status

# Restart service
/etc/init.d/internet_led restart

# Check logs
tail -f /tmp/internet_led.log
```

## 🗑️ Uninstallation

To completely remove the service:

### Method 1: Via Menu
1. Run installer: `./install.sh`
2. Choose Option 4 (Uninstall Completely)
3. Confirm with "yes"

### Method 2: Manual Commands
```bash
/etc/init.d/internet_led stop
/etc/init.d/internet_led disable
rm -f /etc/init.d/internet_led /bin/internet_led_status.sh /etc/config/internet_led
rm -f /tmp/internet_led.log /var/run/internet_led.pid
killall -9 internet_led_status.sh 2>/dev/null
```

## ⚠️ Requirements

- **OpenWRT**: Version 18.06+ or 21.02+
- **Access**: Root SSH access to router
- **LED Support**: Router with controllable LEDs via `/sys/class/leds/`
- **Commands**: Basic shell access

## 📱 Common Router Models

### Google WiFi (AC-1304)
- LED paths: `/sys/class/leds/led1:green/brightness`, etc.
- Default config works out of the box

### Generic OpenWRT Routers
- Use Option 2 (Manual Configuration) to set correct LED paths
- Check `/sys/class/leds/` for available LEDs

## 🆘 Support

If you need help:

1. **Run diagnostics**: Use Option 5 from the installer menu
2. **Check logs**: `tail -f /tmp/internet_led.log`
3. **Verify router**: Check `/sys/class/leds/` for LED interfaces
4. **Test connectivity**: `ping 8.8.8.8`

## 📋 Files Reference

### System Files Created:
- `/bin/internet_led_status.sh` - Main monitoring script
- `/etc/init.d/internet_led` - Service management script  
- `/etc/config/internet_led` - Configuration file
- `/tmp/internet_led.log` - Log file
- `/var/run/internet_led.pid` - Process ID file

### Commands Available:
```bash
/etc/init.d/internet_led start    # Start service
/etc/init.d/internet_led stop     # Stop service
/etc/init.d/internet_led restart  # Restart service
/etc/init.d/internet_led status   # Check status
/etc/init.d/internet_led enable   # Enable auto-start
```

---

**Version**: 7.1 Fixed
**Author**: MiniMax Agent
**Updated**: November 2025