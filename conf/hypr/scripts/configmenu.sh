#!/usr/bin/env bash

CONF_DIR="$HOME/.config/hypr/"

# Fancy human-readable names mapped to actual files
declare -A LABELS=(
  ["Apps"]="conf/apps.conf"
  ["Autostart"]="conf/autostart.conf"
  ["Keybinds"]="conf/binds.conf"
  ["Environment Variables"]="conf/env.conf"
  ["Input"]="conf/input.conf"
  ["Look & Feel"]="conf/looknfeel.conf"
  ["Monitors"]="conf/monitors.conf"
  ["Permissions"]="conf/permissions.conf"
  ["Windows & Workspaces"]="conf/windowsworkspaces.conf"
  ["Hyprlock"]="hyprlock.conf"
  ["Hypridle"]="hypridle.conf"
  ["Hyprpaper"]="hyprpaper.conf"
  ["Waybar"]="../waybar/config"
  ["Waybar Styling"]="../waybar/style.css"
)

# Build the menu list
menu_items=$(printf "%s\n" "${!LABELS[@]}")

choice=$(printf "%s" "$menu_items" | fuzzel --dmenu --prompt "Hypr Config:")

# If something was selected, open it
if [[ -n "$choice" ]]; then
  file="${LABELS[$choice]}"
  kitty -e nvim "$CONF_DIR/$file"
fi
