#!/bin/bash

clear
echo "---------------------------------------------------"
echo "Welcome to the Blink42 Hyprland Dotfiles Installer!"
echo "---------------------------------------------------"

# Detect distro family
if command -v pacman >/dev/null 2>&1; then
  DISTRO="arch"
elif command -v dnf >/dev/null 2>&1; then
  DISTRO="fedora"
elif command -v apt >/dev/null 2>&1; then
  DISTRO="deb"
else
  DISTRO="unknown"
fi

case "$DISTRO" in
arch)
  echo "Detected Arch-based system."
  echo "Installing..."
  sudo pacman -S --needed hyprland hyprpaper hypridle hyprlock waybar fuzzel kitty neovim
  ;;

fedora)
  echo "Detected Fedora-based system."

  echo "Adding Copr repos…"
  for repo in hyprland waybar-hyprland hypridle hyprpaper hyprlock; do
    sudo dnf copr enable solopasha/$repo -y
  done

  echo "Installing packages…"
  sudo dnf install -y hyprland hyprpaper hypridle hyprlock waybar fuzzel kitty neovim
  ;;

deb)
  echo "DISTRO NOT SUPPORTED. TRY USING ARCH OR FEDORA."
  exit 1
  ;;

*)
  echo "UNKNOWN DISTRO — TRY USING ARCH OR FEDORA. (dont worry those are the only ones supported)"
  exit 1
  ;;
esac

echo "Packages installed. Cloning repository..."

TMPDIR=$(mktemp -d)
git clone --depth 1 https://github.com/Blink4252/hyprland-dots.git "$TMPDIR"

CONFIG_DIR="$HOME/.config"
REPO_CONF="$TMPDIR/conf"

mkdir -p "$CONFIG_DIR"

echo "Linking config files..."
for dir in hypr waybar fuzzel nvim kitty; do
  mkdir "$CONFIG_DIR/$dir"
  mkdir "$CONFIG_DIR/../old-dots
  mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/../old-dots"
  cp -r "$REPO_CONF/$dir" "$CONFIG_DIR/$dir"
done

echo "Cleaning up..."
rm -rf "$TMPDIR"

echo "Dotfiles installed!"
echo "Installation complete! You may now restart and launch Hyprland!"
