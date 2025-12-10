#!/usr/bin/env bash
# Bluetooth device manager using bluetoothctl and rofi

COMMAND_TIMEOUT=10

# Check if bluetooth is powered on
is_bluetooth_on() {
    bluetoothctl show | grep -q "Powered: yes"
}

# Get paired devices
get_paired_devices() {
    bluetoothctl devices Paired 2>/dev/null
}

# Check if a device is connected
is_connected() {
    local mac=$1
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"
}

# Connect to a device
connect_device() {
    local mac=$1
    local name=$2
    if timeout $COMMAND_TIMEOUT bluetoothctl connect "$mac" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Connected to $name" -i bluetooth
        return 0
    else
        notify-send "Bluetooth" "Failed to connect to $name" -u critical -i bluetooth
        return 1
    fi
}

# Disconnect from a device
disconnect_device() {
    local mac=$1
    local name=$2
    if timeout $COMMAND_TIMEOUT bluetoothctl disconnect "$mac" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Disconnected from $name" -i bluetooth
        return 0
    else
        notify-send "Bluetooth" "Failed to disconnect from $name" -u critical -i bluetooth
        return 1
    fi
}

# Remove (unpair) a device
remove_device() {
    local mac=$1
    local name=$2
    if timeout $COMMAND_TIMEOUT bluetoothctl remove "$mac" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Removed $name" -i bluetooth
        return 0
    else
        notify-send "Bluetooth" "Failed to remove $name" -u critical -i bluetooth
        return 1
    fi
}

# Pair with a new device
pair_device() {
    local mac=$1
    local name=$2

    notify-send "Bluetooth" "Pairing with $name..." -i bluetooth

    if ! timeout $COMMAND_TIMEOUT bluetoothctl pair "$mac" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Failed to pair with $name" -u critical -i bluetooth
        return 1
    fi

    if ! timeout $COMMAND_TIMEOUT bluetoothctl trust "$mac" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Paired but failed to trust $name" -u normal -i bluetooth
    fi

    if timeout $COMMAND_TIMEOUT bluetoothctl connect "$mac" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Paired and connected to $name" -i bluetooth
        return 0
    else
        notify-send "Bluetooth" "Paired $name but failed to connect" -u normal -i bluetooth
        return 1
    fi
}

# Toggle bluetooth power
toggle_power() {
    if is_bluetooth_on; then
        bluetoothctl power off >/dev/null 2>&1
        notify-send "Bluetooth" "Bluetooth powered off" -i bluetooth
    else
        bluetoothctl power on >/dev/null 2>&1
        notify-send "Bluetooth" "Bluetooth powered on" -i bluetooth
    fi
}

# Scan for new devices
scan_for_devices() {
    notify-send "Bluetooth" "Scanning for devices... (20 seconds)" -i bluetooth

    # Start scanning
    bluetoothctl scan on >/dev/null 2>&1 &
    SCAN_PID=$!

    # Wait for scan
    sleep 20

    # Stop scanning
    bluetoothctl scan off >/dev/null 2>&1
    kill $SCAN_PID 2>/dev/null

    # Get all devices
    ALL_DEVICES=$(bluetoothctl devices 2>/dev/null)
    PAIRED_DEVICES=$(bluetoothctl devices Paired 2>/dev/null)

    # Filter out paired devices to get only new ones
    NEW_DEVICES=""
    while IFS= read -r device; do
        MAC=$(echo "$device" | awk '{print $2}')
        NAME=$(echo "$device" | sed 's/^Device [^ ]* //')

        # Check if this device is not already paired
        if ! echo "$PAIRED_DEVICES" | grep -q "$MAC"; then
            NEW_DEVICES+="⊕ $NAME"$'\n'
            device_map["⊕ $NAME"]=$MAC
        fi
    done <<< "$ALL_DEVICES"

    if [[ -z "$NEW_DEVICES" ]]; then
        rofi -e "No new devices found"
        return
    fi

    # Show new devices menu
    SELECTED=$(echo -n "$NEW_DEVICES" | rofi -dmenu -p "Pair Device" -i -no-custom)

    if [[ -n "$SELECTED" ]]; then
        DEVICE_MAC="${device_map[$SELECTED]}"
        DEVICE_NAME=$(echo "$SELECTED" | sed 's/^⊕ //')
        pair_device "$DEVICE_MAC" "$DEVICE_NAME"
    fi
}

# Show remove device menu
show_remove_menu() {
    declare -A remove_device_map
    REMOVE_MENU=""

    PAIRED=$(get_paired_devices)

    if [[ -z "$PAIRED" ]]; then
        rofi -e "No paired devices to remove"
        return
    fi

    while IFS= read -r line; do
        MAC=$(echo "$line" | awk '{print $2}')
        NAME=$(echo "$line" | sed 's/^Device [^ ]* //')

        MENU_ENTRY="🗑️ $NAME"
        REMOVE_MENU+="$MENU_ENTRY"$'\n'
        remove_device_map["$MENU_ENTRY"]=$MAC
    done <<< "$PAIRED"

    SELECTED=$(echo -n "$REMOVE_MENU" | rofi -dmenu -p "Remove Device" -i -no-custom)

    if [[ -n "$SELECTED" ]]; then
        DEVICE_MAC="${remove_device_map[$SELECTED]}"
        DEVICE_NAME=$(echo "$SELECTED" | sed 's/^🗑️ //')

        # Confirm removal
        if echo -e "Yes\nNo" | rofi -dmenu -p "Remove $DEVICE_NAME?" -i | grep -q "Yes"; then
            remove_device "$DEVICE_MAC" "$DEVICE_NAME"
        fi
    fi
}

# Main menu
show_main_menu() {
    declare -A device_map
    MENU=""

    # Check if bluetooth is on
    if ! is_bluetooth_on; then
        MENU="⚡ Power: Off (Click to turn on)"$'\n'
    else
        # Add paired devices
        PAIRED=$(get_paired_devices)

        if [[ -n "$PAIRED" ]]; then
            while IFS= read -r line; do
                MAC=$(echo "$line" | awk '{print $2}')
                NAME=$(echo "$line" | sed 's/^Device [^ ]* //')

                if is_connected "$MAC"; then
                    INDICATOR="◉"
                    STATUS=" (Connected)"
                else
                    INDICATOR="○"
                    STATUS=" (Disconnected)"
                fi

                MENU_ENTRY="$INDICATOR $NAME$STATUS"
                MENU+="$MENU_ENTRY"$'\n'
                device_map["$MENU_ENTRY"]=$MAC
            done <<< "$PAIRED"

            MENU+="━━━━━━━━━━━━━━━━━━━━"$'\n'
        fi

        # Add management options
        MENU+="🔍 Scan for New Devices"$'\n'
        MENU+="🗑️ Remove Device"$'\n'
        MENU+="⚡ Power: On (Click to turn off)"
    fi

    # Show menu
    SELECTED=$(echo -n "$MENU" | rofi -dmenu -p "Bluetooth" -i -no-custom)

    # Handle selection
    if [[ -z "$SELECTED" ]]; then
        exit 0
    elif [[ "$SELECTED" == "🔍 Scan for New Devices" ]]; then
        scan_for_devices
    elif [[ "$SELECTED" == "🗑️ Remove Device" ]]; then
        show_remove_menu
    elif [[ "$SELECTED" == *"Power:"* ]]; then
        toggle_power
    else
        # It's a device - toggle connection
        DEVICE_MAC="${device_map[$SELECTED]}"
        DEVICE_NAME=$(echo "$SELECTED" | sed -E 's/^[◉○] (.*) \((Connected|Disconnected)\)$/\1/')

        if is_connected "$DEVICE_MAC"; then
            disconnect_device "$DEVICE_MAC" "$DEVICE_NAME"
        else
            connect_device "$DEVICE_MAC" "$DEVICE_NAME"
        fi
    fi
}

# Run main menu
show_main_menu
