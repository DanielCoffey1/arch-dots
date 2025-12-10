#!/usr/bin/env bash
# Audio device switcher for PipeWire via wpctl and rofi

MODE=$1

if [[ "$MODE" != "output" && "$MODE" != "input" ]]; then
    echo "Usage: $0 {output|input}"
    exit 1
fi

# Get wpctl status output
STATUS=$(wpctl status)

# Extract devices based on mode
if [[ "$MODE" == "output" ]]; then
    # Get sinks (outputs) - lines between "Sinks:" and "Sources:"
    DEVICES=$(echo "$STATUS" | awk '/├─ Sinks:/,/├─ Sources:/' | grep -E '^\s*│\s+\*?\s+[0-9]+\.')
    PROMPT="Audio Output"
elif [[ "$MODE" == "input" ]]; then
    # Get sources (inputs) - lines between "Sources:" and "Filters:"
    DEVICES=$(echo "$STATUS" | awk '/├─ Sources:/,/├─ Filters:/' | grep -E '^\s*│\s+\*?\s+[0-9]+\.')
    PROMPT="Audio Input"
fi

# Check if devices were found
if [[ -z "$DEVICES" ]]; then
    rofi -e "No audio devices found"
    exit 0
fi

# Parse devices and create menu
declare -A device_map
MENU=""

while IFS= read -r line; do
    # Check if this is the default device (has asterisk)
    if echo "$line" | grep -q '^\s*│\s*\*'; then
        IS_DEFAULT="yes"
        INDICATOR="◉"
    else
        IS_DEFAULT="no"
        INDICATOR="○"
    fi

    # Extract device ID (number before the dot)
    ID=$(echo "$line" | sed -E 's/^[^0-9]*([0-9]+)\..*/\1/')

    # Extract device name (between dot and bracket)
    NAME=$(echo "$line" | sed -E 's/^[^0-9]*[0-9]+\.\s*([^[]+).*/\1/' | sed 's/[[:space:]]*$//')

    # Build menu entry
    MENU_ENTRY="$INDICATOR $NAME"
    MENU+="$MENU_ENTRY"$'\n'

    # Store ID mapping
    device_map["$MENU_ENTRY"]=$ID
done <<< "$DEVICES"

# Show rofi menu and get selection
SELECTED=$(echo -n "$MENU" | rofi -dmenu -p "$PROMPT" -i -no-custom)

# Exit if nothing selected
if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# Get device ID from selection
DEVICE_ID="${device_map[$SELECTED]}"

if [[ -n "$DEVICE_ID" ]]; then
    # Set as default device
    wpctl set-default "$DEVICE_ID"
fi
