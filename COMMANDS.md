# 📋 Internet LED Controller - Complete Command Reference

## 🚀 Installation Commands

### Quick Installation
```bash
# Method 1: Direct installation (recommended)
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_simple.sh | sh

# Method 2: Download and run
wget -O install_simple.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_simple.sh
chmod +x install_simple.sh
./install_simple.sh

# Method 3: One-click setup with menu
wget -O quick_setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/quick_setup.sh
chmod +x quick_setup.sh
./quick_setup.sh
```

### Manual Installation (Step by Step)
```bash
# 1. Connect to router
ssh root@192.168.1.1

# 2. Create directories
mkdir -p /bin /etc/config

# 3. Download main script
wget -O /bin/internet_led_status.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/internet_led_status.sh

# 4. Download service script
wget -O /etc/init.d/internet_led https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/internet_led

# 5. Download configuration
wget -O /etc/config/internet_led https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/ac1304_config_sample

# 6. Set permissions
chmod +x /bin/internet_led_status.sh
chmod +x /etc/init.d/internet_led

# 7. Enable and start
/etc/init.d/internet_led enable
/etc/init.d/internet_led start
```

## 🔧 Service Management Commands

### Basic Service Control
```bash
# Start the service
/etc/init.d/internet_led start

# Stop the service
/etc/init.d/internet_led stop

# Restart the service
/etc/init.d/internet_led restart

# Check service status
/etc/init.d/internet_led status

# Enable auto-start on boot
/etc/init.d/internet_led enable

# Disable auto-start on boot
/etc/init.d/internet_led disable

# Check if enabled for boot
/etc/init.d/internet_led enabled
```

### Advanced Service Control
```bash
# Force restart (kill and start)
/etc/init.d/internet_led stop
sleep 2
/etc/init.d/internet_led start

# Check running processes
ps | grep internet_led

# Kill manually if stuck
killall -9 internet_led_status.sh

# Check PID file
cat /var/run/internet_led.pid
```

## 🧪 Testing and Diagnostics

### LED Testing
```bash
# List all available LEDs
ls /sys/class/leds/

# Test individual LEDs
echo 255 > /sys/class/leds/led1:green/brightness    # Turn on green
echo 0 > /sys/class/leds/led1:green/brightness     # Turn off green
echo 255 > /sys/class/leds/led1:amber/brightness   # Turn on amber/red
echo 0 > /sys/class/leds/led1:amber/brightness     # Turn off amber/red
echo 255 > /sys/class/leds/led0:blue/brightness    # Turn on blue
echo 0 > /sys/class/leds/led0:blue/brightness      # Turn off blue

# Test all LEDs at once
for led in /sys/class/leds/*/brightness; do
    echo "Testing $led"
    echo 255 > "$led"
    sleep 1
    echo 0 > "$led"
done
```

### Network Testing
```bash
# Test internet connectivity
ping -c 3 8.8.8.8

# Test DNS resolution
nslookup google.com

# Test with different targets
ping -c 3 1.1.1.1          # Cloudflare DNS
ping -c 3 9.9.9.9          # Quad9 DNS
ping -c 3 google.com       # DNS resolution

# Test connectivity timeout
ping -c 1 -W 5 8.8.8.8     # 5 second timeout
```

### System Diagnostics
```bash
# Run complete test suite
wget -O test_installation.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/test_installation.sh
chmod +x test_installation.sh
./test_installation.sh

# Run troubleshooting script
wget -O troubleshoot.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/troubleshoot.sh
chmod +x troubleshoot.sh
./troubleshoot.sh

# Check LED detection
wget -O detect_leds.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/detect_leds.sh
chmod +x detect_leds.sh
./detect_leds.sh
```

## 📊 Monitoring and Logs

### Log Commands
```bash
# View real-time logs
logread -f | grep internet_led

# View recent logs
logread | grep internet_led | tail -20

# View application log
tail -f /tmp/internet_led.log

# View last 50 log entries
tail -50 /tmp/internet_led.log

# Search log for specific events
grep "Setting LED" /tmp/internet_led.log
grep "$(date +%Y-%m-%d)" /tmp/internet_led.log

# Count log entries
wc -l /tmp/internet_led.log

# Clear logs
> /tmp/internet_led.log
```

### Performance Monitoring
```bash
# Check memory usage
free -m

# Check CPU usage
top | grep internet_led

# Check process details
ps aux | grep internet_led_status.sh

# Monitor for 10 seconds
watch -n 2 'ps | grep internet_led'
```

## ⚙️ Configuration Commands

### Edit Configuration
```bash
# View current configuration
cat /etc/config/internet_led

# Edit configuration file
vi /etc/config/internet_led

# Or use UCI commands
uci show internet_led

# Update configuration using UCI
uci set internet_led.main.check_interval='30'    # Change check interval to 30 seconds
uci set internet_led.main.ping_target='1.1.1.1' # Change ping target
uci commit internet_led

# Restart service after config change
/etc/init.d/internet_led restart
```

### Common Configuration Changes
```bash
# Change check interval to 30 seconds
uci set internet_led.main.check_interval='30'
uci commit internet_led

# Change ping target to Cloudflare DNS
uci set internet_led.main.ping_target='1.1.1.1'
uci commit internet_led

# Disable logging
uci set internet_led.main.log_file='/dev/null'
uci commit internet_led

# Reset to defaults
uci set internet_led.main.check_interval='10'
uci set internet_led.main.ping_target='8.8.8.8'
uci set internet_led.main.log_file='/tmp/internet_led.log'
uci commit internet_led
```

## 🗑️ Uninstallation Commands

### Complete Uninstall
```bash
# Method 1: Using uninstall script
wget -O uninstall_complete.sh https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/uninstall_complete.sh
chmod +x uninstall_complete.sh
./uninstall_complete.sh

# Method 2: Manual uninstall
/etc/init.d/internet_led stop
/etc/init.d/internet_led disable
rm -f /etc/init.d/internet_led
rm -f /bin/internet_led_status.sh
rm -f /etc/config/internet_led
rm -f /tmp/internet_led.log
rm -f /var/run/internet_led.pid
killall -9 internet_led_status.sh 2>/dev/null

# Method 3: Nuclear option (everything)
/etc/init.d/internet_led stop
/etc/init.d/internet_led disable
rm -f /etc/init.d/internet_led /bin/internet_led_status.sh /etc/config/internet_led
rm -f /tmp/internet_led.log /var/run/internet_led.pid
killall -9 internet_led_status.sh 2>/dev/null
```

## 🔍 Troubleshooting Commands

### Quick Diagnostics
```bash
# Basic status check
/etc/init.d/internet_led status

# Check if process is running
ps | grep internet_led

# Check configuration
cat /etc/config/internet_led

# Check logs
tail -20 /tmp/internet_led.log

# Test internet manually
ping -c 1 8.8.8.8
```

### Advanced Diagnostics
```bash
# Check system resources
free -m
df -h
uptime

# Check network interfaces
ubus call network.interface.wan status
ifconfig

# Check DNS settings
cat /etc/resolv.conf

# Check boot log
logread | grep internet_led | head -10

# Test LED paths
ls -la /sys/class/leds/*/brightness

# Test manual LED control
for led in /sys/class/leds/*/brightness; do
    echo "Testing $led"
    echo 255 > "$led"
    sleep 1
    echo 0 > "$led"
done
```

### Reset Commands
```bash
# Reset service to clean state
/etc/init.d/internet_led stop
killall -9 internet_led_status.sh 2>/dev/null
sleep 2
/etc/init.d/internet_led start

# Reset configuration
cp /etc/config/internet_led /tmp/internet_led.backup
echo 'config internet_led "main"
    option enabled "1"
    option check_interval "10"
    option led_green "/sys/class/leds/led1:green/brightness"
    option led_amber "/sys/class/leds/led1:amber/brightness"
    option led_blue "/sys/class/leds/led0:blue/brightness"
    option log_file "/tmp/internet_led.log"
    option ping_target "8.8.8.8"' > /etc/config/internet_led
/etc/init.d/internet_led restart

# Clear all logs
> /tmp/internet_led.log
logread -c

# Restart router (if all else fails)
reboot
```

## 📱 LuCI Web Interface Commands

### Service Management via Web
```bash
# Access router web interface
firefox http://192.168.1.1

# Or use curl to check status
curl -s http://192.168.1.1/cgi-bin/luci/admin/system/startup | grep internet_led
```

### UCI via Command Line
```bash
# View all internet_led settings
uci show internet_led

# Get specific setting
uci get internet_led.main.check_interval

# Set specific setting
uci set internet_led.main.check_interval='30'
uci commit internet_led

# Delete setting (use with caution)
uci delete internet_led.main.custom_option
uci commit internet_led
```

## 🎯 Common Use Cases

### Deploy to Multiple Routers
```bash
# Create deployment script for multiple routers
for router_ip in 192.168.1.1 192.168.1.2 192.168.1.3; do
    echo "Installing on $router_ip..."
    ssh root@$router_ip "wget -O - https://raw.githubusercontent.com/YOUR_USERNAME/openwrt-led-script/main/install_simple.sh | sh"
done
```

### Monitor Multiple Routers
```bash
# Check status on multiple routers
for router_ip in 192.168.1.1 192.168.1.2; do
    echo "=== $router_ip ==="
    ssh root@$router_ip "/etc/init.d/internet_led status"
    ssh root@$router_ip "tail -5 /tmp/internet_led.log"
done
```

### Backup and Restore Configuration
```bash
# Backup configuration
scp root@192.168.1.1:/etc/config/internet_led ./backup_config

# Restore configuration
scp ./backup_config root@192.168.1.1:/etc/config/internet_led
ssh root@192.168.1.1 "/etc/init.d/internet_led restart"
```

---

**💡 Tip**: Bookmark this page for quick reference!  
**🔧 Need Help?**: Run `./troubleshoot.sh` for automated diagnostics  
**📚 Full Documentation**: See `INSTALLATION_GUIDE.md`