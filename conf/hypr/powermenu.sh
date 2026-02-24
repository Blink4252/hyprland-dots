#!/usr/bin/env bash

# Fancy human-readable names mapped to actual files
declare -A ACTIONS=(
  ["Shutdown"]="shutdown now"
  ["Restart"]="reboot"
  ["Log out"]="hyprctl dispatch exit 0"
  ["Lock"]="hyprlock"
)

# Build the menu list
menu_items=$(printf "%s\n" "${!ACTIONS[@]}")

choice=$(printf "%s" "$menu_items" | fuzzel --dmenu --prompt "Power Menu:")

# If something was selected, open it
if [[ -n "$choice" ]]; then
  eval "${ACTIONS[$choice]}"
fi
