#!/usr/bin/env bash
# Get bluetooth status for waybar

# Check if bluetooth is powered on
if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo '{"text": "󰂲", "class": "off", "tooltip": "Bluetooth Off"}'
    exit 0
fi

# Get number of connected devices
CONNECTED=$(bluetoothctl devices Connected 2>/dev/null | wc -l)

if [[ $CONNECTED -eq 0 ]]; then
    echo '{"text": "", "class": "on", "tooltip": "Bluetooth On - No devices connected"}'
else
    DEVICE_LIST=$(bluetoothctl devices Connected 2>/dev/null | sed 's/^Device [^ ]* //' | paste -sd ", ")
    echo "{\"text\": \"󰂱  $CONNECTED\", \"class\": \"connected\", \"tooltip\": \"Connected: $DEVICE_LIST\"}"
fi
