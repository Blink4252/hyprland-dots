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
    echo "Installing packages..."
    sudo pacman -S --needed hyprland hyprpaper hypridle hyprlock waybar fuzzel kitty neovim
    ;;
  fedora)
    echo "Detected Fedora-based system."
    echo "Adding Copr repos..."
    for repo in hyprland waybar-hyprland hypridle hyprpaper hyprlock; do
      sudo dnf copr enable solopasha/$repo -y
    done
    echo "Installing packages..."
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

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to clone repository. Check your internet connection and try again."
  rm -rf "$TMPDIR"
  exit 1
fi

CONFIG_DIR="$HOME/.config"
OLD_DOTS="$CONFIG_DIR/old-dots"
REPO_CONF="$TMPDIR/conf"

mkdir -p "$CONFIG_DIR"
mkdir -p "$OLD_DOTS"

echo "Backing up existing configs and installing dotfiles..."

for dir in fuzzel hypr kitty nvim waybar; do
  if [ -d "$CONFIG_DIR/$dir" ]; then
    echo "  Backing up existing '$dir' to old-dots..."
    mv "$CONFIG_DIR/$dir" "$OLD_DOTS/$dir"
  fi
  echo "  Copying '$dir'..."
  cp -r "$REPO_CONF/$dir" "$CONFIG_DIR/$dir"
done

echo "Cleaning up..."
rm -rf "$TMPDIR"

echo ""
echo "---------------------------------------------------"
echo "Dotfiles installed successfully!"
echo "Installation complete! You may now restart and launch Hyprland!"
echo "---------------------------------------------------"
