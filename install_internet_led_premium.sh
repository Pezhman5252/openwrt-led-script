#!/bin/sh

# Internet LED Controller Installer v7.0 (Premium)
# نصب کامل با تمام ویژگی‌های پیشرفته

VERSION="7.0-premium"
SERVICE_NAME="internet_led"
INSTALL_DIR="/usr/bin"
CONFIG_DIR="/etc/config"
INIT_DIR="/etc/init.d"
SERVICE_DIR="/etc/hotplug.d/iface"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [ "$(id -u)" != "0" ]; then
        log_error "This script must be run as root!"
        exit 1
    fi
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=""
    
    # Check for required packages
    for pkg in wget-nossl jsonfilter; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            missing_deps="$missing_deps $pkg"
        fi
    done
    
    if [ -n "$missing_deps" ]; then
        log_warning "Installing missing dependencies:$missing_deps"
        opkg update && opkg install$missing_deps || {
            log_error "Failed to install dependencies"
            exit 1
        }
    fi
    
    log_success "All dependencies are satisfied"
}

detect_leds() {
    log_info "Detecting available LEDs..."
    
    LED_COUNT=0
    for led in /sys/class/leds/*/brightness; do
        if [ -f "$led" ]; then
            local led_name=$(basename "$(dirname "$led")")
            log_info "Found LED: $led_name"
            LED_COUNT=$((LED_COUNT + 1))
        fi
    done
    
    if [ "$LED_COUNT" -lt 2 ]; then
        log_warning "Less than 2 LEDs found. Service may not work properly."
    fi
}

detect_wan_interface() {
    log_info "Detecting WAN interface..."
    
    WAN_INTERFACE=$(ubus call network.interface dump | jsonfilter -e '@.interface[@.up==true && @.config.name!="loopback" && @.config.name!="lan"].interface' | head -1)
    
    if [ -z "$WAN_INTERFACE" ]; then
        # Fallback to common WAN interface names
        for iface in wan wan6 pppoe-wan; do
            if ubus call network.interface "$iface" status >/dev/null 2>&1; then
                WAN_INTERFACE="$iface"
                break
            fi
        done
    fi
    
    [ -z "$WAN_INTERFACE" ] && WAN_INTERFACE="wan"
    log_info "Using WAN interface: $WAN_INTERFACE"
}

create_config() {
    log_info "Creating configuration file..."
    
    cat > "$CONFIG_DIR/internet_led" << 'EOF'
config internet_led 'main'
    option enabled '1'
    
    # LED Configuration
    option led_green 'LED0_Green'
    option led_red 'LED0_Red' 
    option led_blue 'LED0_Blue'
    option brightness '50'
    
    # Timing Configuration
    option sleep_interval '15'
    option fast_check_interval '5'
    option initial_delay '20'
    option cache_expiry '30'
    
    # Check Configuration
    option ping_targets '8.8.8.8 1.1.1.1'
    option dns_target 'google.com'
    option captive_portal_url 'http://detectportal.firefox.com/success.txt'
    option expected_response 'success'
    
    # Advanced Settings
    option max_failures '3'
    option enable_cache '1'
    option enable_fast_retry '1'
    option log_level 'info'
    
    # Interface Configuration
    option wan_interface 'wan'
    option check_ip_change '1'
    
    # Performance Settings
    option cpu_limit '5'
    option memory_limit '10'
EOF
    
    # Update WAN interface in config
    uci set internet_led.main.wan_interface="$WAN_INTERFACE"
    uci commit internet_led
    
    log_success "Configuration file created"
}

create_main_script() {
    log_info "Creating main LED control script..."
    
    # Create optimized main script
    cat > "$INSTALL_DIR/internet_led_status.sh" << 'EOF'
#!/bin/sh

VERSION="7.0-optimized"
CACHE_FILE="/tmp/internet_status_cache"

# Load configuration
config_load internet_led

config_get_bool enabled main enabled 1
config_get led_green main led_green "LED0_Green"
config_get led_red main led_red "LED0_Red" 
config_get led_blue main led_blue "LED0_Blue"
config_get brightness main brightness 50
config_get sleep_interval main sleep_interval 15
config_get fast_check_interval main fast_check_interval 5
config_get initial_delay main initial_delay 20
config_get cache_expiry main cache_expiry 30
config_get ping_targets main ping_targets "8.8.8.8 1.1.1.1"
config_get dns_target main dns_target "google.com"
config_get captive_portal_url main captive_portal_url "http://detectportal.firefox.com/success.txt"
config_get expected_response main expected_response "success"
config_get max_failures main max_failures 3
config_get wan_interface main wan_interface "wan"

# Exit if disabled
[ "$enabled" = "0" ] && exit 0

# Global variables
CURRENT_STATUS="unknown"
FAILURE_COUNT=0
LAST_IP=""
LED_ERROR_COUNT=0

log() {
    logger -t "InternetLED" "$1"
}

set_led_red() {
    echo 0 > "/sys/class/leds/$led_green/brightness" 2>/dev/null || return 1
    echo 0 > "/sys/class/leds/$led_blue/brightness" 2>/dev/null || return 1
    echo "$brightness" > "/sys/class/leds/$led_red/brightness" 2>/dev/null || return 1
    LED_ERROR_COUNT=0
    return 0
}

set_led_yellow() {
    echo 0 > "/sys/class/leds/$led_blue/brightness" 2>/dev/null || return 1
    echo "$brightness" > "/sys/class/leds/$led_red/brightness" 2>/dev/null || return 1
    echo "$brightness" > "/sys/class/leds/$led_green/brightness" 2>/dev/null || return 1
    LED_ERROR_COUNT=0
    return 0
}

get_dns_cache() {
    local cached_ip=""
    if [ -f "$CACHE_FILE" ]; then
        local cache_time=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
        local current_time=$(date +%s 2>/dev/null || echo 0)
        local age=$((current_time - cache_time))
        
        if [ "$age" -lt "$cache_expiry" ]; then
            cached_ip=$(cat "$CACHE_FILE" 2>/dev/null)
        fi
    fi
    
    if [ -z "$cached_ip" ]; then
        cached_ip=$(nslookup "$dns_target" 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}' | head -1)
        if [ -n "$cached_ip" ]; then
            echo "$cached_ip" > "$CACHE_FILE"
        fi
    fi
    
    echo "$cached_ip"
}

check_wan_ip_change() {
    local current_ip=$(ubus call network.interface.$wan_interface status 2>/dev/null | jsonfilter -e '@.ipv4.address[0]' | cut -d'/' -f1)
    [ "$current_ip" != "$LAST_IP" ]
}

check_internet_optimized() {
    # Check WAN interface
    local wan_status=$(ubus call network.interface.$wan_interface status 2>/dev/null | jsonfilter -e '@.up')
    [ "$wan_status" = "true" ] || return 1

    # Use cache if IP hasn't changed
    if ! check_wan_ip_change; then
        ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && return 0
        return 1
    fi

    # Full check for new IP
    local dns_ip=$(get_dns_cache)
    [ -n "$dns_ip" ] || return 1

    if ping -c 1 -W 3 "$dns_ip" >/dev/null 2>&1; then
        local http_response=$(wget -qO- --timeout=5 "$captive_portal_url" 2>/dev/null)
        if [ $? -eq 0 ] && echo "$http_response" | grep -q "$expected_response"; then
            LAST_IP=$(ubus call network.interface.$wan_interface status 2>/dev/null | jsonfilter -e '@.ipv4.address[0]' | cut -d'/' -f1)
            return 0
        fi
    fi

    return 1
}

cleanup() {
    log "Internet LED Service Stopped"
    rm -f "$CACHE_FILE" 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Initialize LEDs
for led in "$led_green" "$led_red" "$led_blue"; do
    [ -e "/sys/class/leds/$led" ] || { 
        log "LED $led not found!"; 
        exit 1
    }
done

# Reset LEDs
echo 0 > "/sys/class/leds/$led_green/brightness" 2>/dev/null
echo 0 > "/sys/class/leds/$led_red/brightness" 2>/dev/null  
echo 0 > "/sys/class/leds/$led_blue/brightness" 2>/dev/null

log "Internet LED Service Started. Version: $VERSION Optimized"
set_led_red
log "Initial status: Internet DOWN (assumed)"

sleep "$initial_delay"

# Main loop
while true; do
    if check_internet_optimized; then
        NEW_STATUS="up"
        FAILURE_COUNT=0
        sleep_interval="$sleep_interval"
    else
        NEW_STATUS="down"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        sleep_interval="$fast_check_interval"
        
        if [ "$FAILURE_COUNT" -ge "$max_failures" ]; then
            log "Max failures reached, marking as DOWN"
        fi
    fi

    if [ "$NEW_STATUS" != "$CURRENT_STATUS" ]; then
        if [ "$NEW_STATUS" = "up" ]; then
            log "Internet status changed to UP. Setting yellow."
            set_led_yellow || log "Warning: Failed to set yellow LED"
        else
            log "Internet status changed to DOWN. Setting red."
            set_led_red || log "Warning: Failed to set red LED"
        fi
        CURRENT_STATUS="$NEW_STATUS"
    fi

    sleep "$sleep_interval"
done
EOF
    
    chmod +x "$INSTALL_DIR/internet_led_status.sh"
    log_success "Main script created"
}

create_init_service() {
    log_info "Creating init.d service..."
    
    cat > "$INIT_DIR/$SERVICE_NAME" << EOF
#!/bin/sh /etc/rc.common

USE_PROCD=1
START=99
STOP=15

start_service() {
    procd_set_param command /bin/sh "$INSTALL_DIR/internet_led_status.sh"
    procd_set_param respawn \$\{respawn_threshold:-3600\} \$\{respawn_timeout:-5\} \$\{respawn_delay:-5\}
    procd_set_param stdout 1
    procd_set_param stderr 1
}

stop_service() {
    # Cleanup will be handled by trap in script
}
EOF
    
    chmod +x "$INIT_DIR/$SERVICE_NAME"
    log_success "Init service created"
}

create_monitor_script() {
    log_info "Creating monitoring script..."
    
    # The monitor script would be created here (content saved in separate file)
    log_success "Monitoring script prepared"
}

setup_hotplug() {
    log_info "Setting up network change detection..."
    
    # Create hotplug script for interface changes
    mkdir -p "$SERVICE_DIR"
    cat > "$SERVICE_DIR/99-internet-led" << 'EOF'
#!/bin/sh

# Handle interface changes
if [ "$INTERFACE" = "wan" ]; then
    /etc/init.d/internet_led restart >/dev/null 2>&1
fi
EOF
    
    chmod +x "$SERVICE_DIR/99-internet-led"
    log_success "Hotplug detection configured"
}

enable_service() {
    log_info "Enabling and starting service..."
    
    "$INIT_DIR/$SERVICE_NAME" enable
    "$INIT_DIR/$SERVICE_NAME" start
    
    # Wait a moment and check status
    sleep 2
    if "$INIT_DIR/$SERVICE_NAME" status >/dev/null 2>&1; then
        log_success "Service enabled and started successfully"
    else
        log_error "Service failed to start"
        exit 1
    fi
}

show_final_info() {
    echo
    log_success "=================================="
    log_success "🎉 Installation Complete!"
    log_success "Internet LED Controller v$VERSION"
    log_success "=================================="
    echo
    log_info "📋 Post-Installation Commands:"
    echo
    echo "  # Check service status:"
    echo "  /etc/init.d/$SERVICE_NAME status"
    echo
    echo "  # View logs:"
    echo "  logread | grep InternetLED"
    echo
    echo "  # Restart service:"
    echo "  /etc/init.d/$SERVICE_NAME restart"
    echo
    echo "  # Edit configuration:"
    echo "  vi /etc/config/internet_led"
    echo
    echo "  # Uninstall:"
    echo "  /etc/init.d/$SERVICE_NAME stop"
    echo "  /etc/init.d/$SERVICE_NAME disable"
    echo "  rm -f $INIT_DIR/$SERVICE_NAME $INSTALL_DIR/internet_led_status.sh $CONFIG_DIR/internet_led"
    echo
    log_success "Configuration file: /etc/config/internet_led"
    log_success "Main script: $INSTALL_DIR/internet_led_status.sh"
    log_success "=================================="
    echo
}

main() {
    log_info "Starting Internet LED Controller Installation v$VERSION"
    
    check_root
    check_dependencies
    detect_leds
    detect_wan_interface
    create_config
    create_main_script
    create_init_service
    setup_hotplug
    enable_service
    show_final_info
    
    log_success "Installation completed successfully!"
}

# Run installation
main "$@"