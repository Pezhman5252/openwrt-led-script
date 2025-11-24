#!/bin/sh

# Internet LED Monitor Script v1.0
# بررسی عملکرد و سلامت سرویس

SERVICE_NAME="internet_led"
LOG_TAG="InternetLED"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_service_status() {
    log "=== Service Status Check ==="
    
    if /etc/init.d/$SERVICE_NAME status >/dev/null 2>&1; then
        log "✅ Service is running"
        
        # Process info
        local pid=$(pgrep -f "internet_led_status.sh" | head -1)
        if [ -n "$pid" ]; then
            log "📊 Process ID: $pid"
            log "🧠 Memory usage: $(ps -p $pid -o rss= | awk '{print int($1/1024)}') MB"
            log "⚡ CPU usage: $(ps -p $pid -o %cpu= | awk '{print $1"%"}')"
        fi
    else
        log "❌ Service is not running"
        return 1
    fi
}

check_logs() {
    log "=== Recent Log Analysis ==="
    
    # Last 10 log entries
    log "Recent logs:"
    logread | grep "$LOG_TAG" | tail -10 | while read -r line; do
        log "  $line"
    done
}

check_network_connectivity() {
    log "=== Network Connectivity Test ==="
    
    # WAN interface status
    local wan_status=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.up')
    log "🌐 WAN Interface: $([ "$wan_status" = "true" ] && echo "UP" || echo "DOWN")"
    
    # IP address
    local wan_ip=$(ubus call network.interface.wan status 2>/dev/null | jsonfilter -e '@.ipv4.address[0]' | cut -d'/' -f1)
    log "📍 WAN IP: ${wan_ip:-"Not assigned"}"
    
    # Ping tests
    log "📡 Ping tests:"
    for target in 8.8.8.8 1.1.1.1 google.com; do
        if ping -c 1 -W 2 "$target" >/dev/null 2>&1; then
            log "  ✅ $target - OK"
        else
            log "  ❌ $target - FAILED"
        fi
    done
}

check_leds() {
    log "=== LED Status Check ==="
    
    for led in LED0_Green LED0_Red LED0_Blue; do
        if [ -e "/sys/class/leds/$led/brightness" ]; then
            local brightness=$(cat "/sys/class/leds/$led/brightness" 2>/dev/null)
            log "💡 $led: brightness=$brightness"
        else
            log "⚠️  $led: Not found"
        fi
    done
}

check_performance_metrics() {
    log "=== Performance Metrics ==="
    
    # Cache file status
    if [ -f "/tmp/internet_status_cache" ]; then
        local cache_age=$(stat -c %Y /tmp/internet_status_cache 2>/dev/null)
        local current_time=$(date +%s 2>/dev/null)
        local age=$((current_time - cache_age))
        log "💾 Cache age: ${age}s"
        log "💾 Cache content: $(cat /tmp/internet_status_cache 2>/dev/null)"
    else
        log "💾 No cache file found"
    fi
    
    # Disk usage
    local disk_usage=$(df -h /tmp | awk 'NR==2 {print $5}' | sed 's/%//')
    log "💿 /tmp usage: ${disk_usage}%"
}

check_errors() {
    log "=== Error Analysis ==="
    
    # Check for common errors in last hour
    local one_hour_ago=$(date -d '1 hour ago' '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
    
    log "Checking for errors in the last hour..."
    if command -v logread >/dev/null 2>&1; then
        local error_count=$(logread | grep -c "$LOG_TAG.*error\|$LOG_TAG.*failed\|$LOG_TAG.*timeout" 2>/dev/null || echo "0")
        log "📊 Error count in last hour: $error_count"
        
        if [ "$error_count" -gt 10 ]; then
            log "⚠️  High error rate detected!"
        fi
    fi
}

run_diagnostics() {
    log "========================================"
    log "🔍 Internet LED Diagnostics Report"
    log "Generated: $(date)"
    log "========================================"
    
    check_service_status
    echo
    
    check_network_connectivity
    echo
    
    check_leds
    echo
    
    check_performance_metrics
    echo
    
    check_logs
    echo
    
    check_errors
    
    log "========================================"
    log "✅ Diagnostics completed"
    log "========================================"
}

generate_report() {
    local report_file="/tmp/internet_led_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        run_diagnostics
    } > "$report_file"
    
    log "📄 Report saved to: $report_file"
    
    # Upload to remote server if configured (optional)
    if [ -n "$REMOTE_UPLOAD_URL" ]; then
        if command -v wget >/dev/null 2>&1; then
            wget -q --post-file="$report_file" "$REMOTE_UPLOAD_URL" && log "📤 Report uploaded successfully"
        fi
    fi
}

case "${1:-monitor}" in
    monitor)
        run_diagnostics
        ;;
    report)
        generate_report
        ;;
    service)
        check_service_status
        ;;
    network)
        check_network_connectivity
        ;;
    leds)
        check_leds
        ;;
    performance)
        check_performance_metrics
        ;;
    errors)
        check_errors
        ;;
    logs)
        check_logs
        ;;
    *)
        echo "Usage: $0 {monitor|report|service|network|leds|performance|errors|logs}"
        echo
        echo "Commands:"
        echo "  monitor     - Full system diagnostics (default)"
        echo "  report      - Generate detailed report file"
        echo "  service     - Check service status only"
        echo "  network     - Test network connectivity"
        echo "  leds        - Check LED status"
        echo "  performance - Show performance metrics"
        echo "  errors      - Analyze recent errors"
        echo "  logs        - Show recent logs"
        exit 1
        ;;
esac