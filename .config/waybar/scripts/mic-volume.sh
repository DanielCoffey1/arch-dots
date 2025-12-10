#!/usr/bin/env bash
# Get microphone volume and mute status for waybar

# Get volume for default source
VOLUME_OUTPUT=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

if [[ $? -ne 0 ]] || [[ -z "$VOLUME_OUTPUT" ]]; then
    # No default source
    echo '{"text": "N/A", "class": "error", "tooltip": "No microphone"}'
    exit 0
fi

# Parse output: "Volume: 0.85" or "Volume: 0.85 [MUTED]"
VOLUME=$(echo "$VOLUME_OUTPUT" | awk '{print $2}')
PERCENTAGE=$(awk "BEGIN {printf \"%.0f\", $VOLUME * 100}")
IS_MUTED=$(echo "$VOLUME_OUTPUT" | grep -q "MUTED" && echo "yes" || echo "no")

# Determine icon based on level and mute status
if [[ "$IS_MUTED" == "yes" ]]; then
    ICON=""
    CLASS="muted"
elif (( PERCENTAGE > 66 )); then
    ICON=""
    CLASS=""
elif (( PERCENTAGE > 33 )); then
    ICON=""
    CLASS=""
else
    ICON=""
    CLASS=""
fi

# Output JSON for waybar
if [[ "$IS_MUTED" == "yes" ]]; then
    echo "{\"text\": \"$ICON  $PERCENTAGE%\", \"class\": \"$CLASS\", \"tooltip\": \"Microphone: $PERCENTAGE% (Muted)\"}"
else
    echo "{\"text\": \"$ICON  $PERCENTAGE%\", \"class\": \"$CLASS\", \"tooltip\": \"Microphone: $PERCENTAGE%\"}"
fi
