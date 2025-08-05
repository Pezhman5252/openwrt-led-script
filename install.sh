#!/bin/sh

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# --- Step 1: Dependency Check and Installation ---
echo "Checking and installing required packages (wget-ssl, ca-bundle)..."
opkg update
opkg install wget-ssl ca-bundle
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to install required packages."
    echo "Please check your internet connection and opkg configuration."
    exit 1
fi

# ====================================================================
#  <<<<<<<<<<<<<<<<<<<<<<   تغییر کلیدی اینجاست   >>>>>>>>>>>>>>>>>>>>
#
# Clear the shell's command path cache.
# This forces the shell to find the new, full-featured wget binary.
hash -r
#
# ====================================================================

echo "Dependencies are satisfied."
echo "----------------------------------------"


# --- Step 2: Main Installation ---
# Repository variables
REPO_USER="Pezhman5252"
REPO_NAME="openwrt-led-script"
BRANCH="main"

# File URLs
SERVICE_FILE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH/files/etc/init.d/internet_led"
SCRIPT_FILE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH/files/usr/bin/internet_led_status.sh"

# Installation paths
SERVICE_PATH="/etc/init.d/internet_led"
SCRIPT_PATH="/usr/bin/internet_led_status.sh"

echo "Starting the Smart LED Controller installation..."

# Download the service file using the now-installed full wget
echo "-> Downloading the service file..."
wget -q "$SERVICE_FILE_URL" -O "$SERVICE_PATH"
if [ "$?" -ne 0 ]; then
    echo "Error downloading the service file."
    exit 1
fi

# Download the main script
echo "-> Downloading the main script..."
wget -q "$SCRIPT_FILE_URL" -O "$SCRIPT_PATH"
if [ "$?" -ne 0 ]; then
    echo "Error downloading the main script."
    exit 1
fi

echo "-> Setting executable permissions..."
chmod +x "$SERVICE_PATH"
chmod +x "$SCRIPT_PATH"

echo "-> Enabling and starting the service..."
$SERVICE_PATH enable
$SERVICE_PATH start

echo ""
echo "Installation completed successfully!"
echo "The LED controller script is now active."
echo "For customization (like changing LED names), edit the file: $SCRIPT_PATH"
echo "Then, restart the service with: /etc/init.d/internet_led restart"
