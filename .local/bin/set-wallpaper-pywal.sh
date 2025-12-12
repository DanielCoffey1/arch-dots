#!/bin/bash
# Pywal Wallpaper and Color Scheme Script
# Sets wallpaper and applies color scheme to all apps

# Check if image file is provided
if [ -z "$1" ]; then
    notify-send "Pywal Error" "No image file provided"
    exit 1
fi

IMAGE_PATH="$1"

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    notify-send "Pywal Error" "Image file not found: $IMAGE_PATH"
    exit 1
fi

# Generate color scheme with pywal
notify-send "Pywal" "Generating color scheme from image..."
wal -i "$IMAGE_PATH" -n

# Kill existing swaybg instances
killall swaybg 2>/dev/null

# Set wallpaper with swaybg
swaybg -i "$IMAGE_PATH" -m fill &

# Source the new colors
source ~/.cache/wal/colors.sh

# Reload Hyprland configuration to apply new colors
hyprctl reload

# Restart waybar to apply new colors
killall waybar
uwsm-app -- waybar &

# Restart mako to apply new colors
killall mako
uwsm-app -- mako &

# The pywal templates will automatically generate config files for:
# - Rofi (if template exists)
# - Kitty (colors are auto-reloaded)
# - Any other apps with templates in ~/.config/wal/templates/

notify-send "Pywal" "Wallpaper and color scheme applied successfully!"
