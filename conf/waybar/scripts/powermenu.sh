#!/usr/bin/env bash
# ~/.config/waybar/scripts/powermenu.sh

# Always output a power icon for Waybar to render
echo "⏻"

# If clicked, show wofi menu
if [[ "$WAYBAR_CLICKED" ]]; then
  CHOICE=$(echo -e "Logout\nReboot\nShutdown" | wofi --dmenu --prompt "Power:")
  case "$CHOICE" in
  Logout) hyprctl dispatch exit ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
  esac
fi
