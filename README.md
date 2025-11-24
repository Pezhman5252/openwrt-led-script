# 🌐 Internet LED Controller - Complete Package v7.1

## 📦 Package Contents

This complete package contains everything needed for installation, management, testing, and uninstallation on any OpenWRT router:

### 🚀 Installation & Setup
- **quick_setup.sh** - One-click setup with interactive menu (RECOMMENDED)
- **install_simple.sh** - Direct installer for experienced users
- **INSTALLATION_GUIDE.md** - Comprehensive installation and troubleshooting guide
- **COMMANDS.md** - Complete command reference

### 🔧 Management & Diagnostics  
- **test_installation.sh** - Complete installation verification and testing
- **troubleshoot.sh** - Automated troubleshooting and diagnostics
- **detect_leds.sh** - LED detection for your specific router model

### 🗑️ Maintenance
- **uninstall_complete.sh** - Complete removal with verification

## 🎯 Quick Installation

### ⚡ Super Easy (Recommended):
```bash
# One-click setup with interactive menu
wget -O quick_setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/quick_setup.sh
chmod +x quick_setup.sh
./quick_setup.sh
```

### 🚀 Direct Installation (For experienced users):
```bash
# Direct installation
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_simple.sh | sh

# Or download and run
wget -O install_simple.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_simple.sh
chmod +x install_simple.sh
./install_simple.sh
```

### For other router models:
1. Run LED detection first:
   ```bash
   wget -O detect_leds.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/detect_leds.sh
   chmod +x detect_leds.sh
   ./detect_leds.sh
   ```

2. Install the main script:
   ```bash
   wget -O install_simple.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_simple.sh
   chmod +x install_simple.sh
   ./install_simple.sh
   ```

3. Customize LED paths if needed using the detection results

## 💡 What This Does

The Internet LED Controller automatically:
- ✅ Shows **Yellow LED** when internet is connected
- ❌ Shows **Red LED** when internet is disconnected  
- 🔄 Monitors connectivity every 10 seconds
- 📊 Logs all status changes to `/tmp/internet_led.log`
- 🚀 Starts automatically on router boot

## 🔧 Management & Testing

```bash
# Interactive menu (best for beginners)
./quick_setup.sh

# Check service status
/etc/init.d/internet_led status

# Restart service
/etc/init.d/internet_led restart

# Run complete tests
./test_installation.sh

# Run troubleshooting
./troubleshoot.sh

# Detect LEDs for your router
./detect_leds.sh

# Complete uninstall
./uninstall_complete.sh

# View logs
logread | grep internet_led
```

## 📚 Documentation

- **INSTALLATION_GUIDE.md** - Comprehensive installation and troubleshooting guide
- **COMMANDS.md** - Complete command reference with examples
- **README.md** - This quick start guide

## 🗑️ Complete Uninstallation

To completely remove the service:
```bash
# Run the complete uninstaller
wget -O uninstall_complete.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/uninstall_complete.sh
chmod +x uninstall_complete.sh
./uninstall_complete.sh
```

## ⚠️ Requirements

- OpenWRT 18.06+ or 21.02+
- Root SSH access to router
- Router with controllable LEDs via `/sys/class/leds/`

## 🆘 Support

If you encounter issues:
1. Check the installation guide
2. Run the troubleshooting script
3. Verify your router's LED paths
4. Check system logs

---
**Version**: 7.1 Final  
**Author**: MiniMax Agent  
**License**: MIT