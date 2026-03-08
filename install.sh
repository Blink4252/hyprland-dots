#!/bin/bash
clear
echo "---------------------------------------------------"
echo "Welcome to the Blink42 Hyprland Dotfiles Installer!"
echo "---------------------------------------------------"

# Arrow key menu function
# Usage: arrow_menu "Question" "option1" "option2" ...
# Returns selected index in $ARROW_SELECTED
arrow_menu() {
  local question="$1"
  shift
  local options=("$@")
  local selected=0

  print_menu() {
    echo -ne "\r $question  "
    for i in "${!options[@]}"; do
      if [ "$i" -eq "$selected" ]; then
        echo -ne " > ${options[$i]}  "
      else
        echo -ne "   ${options[$i]}  "
      fi
    done
  }

  print_menu
  while true; do
    read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key
      case $key in
        "[D") selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} )); print_menu ;;
        "[C") selected=$(( (selected + 1) % ${#options[@]} )); print_menu ;;
      esac
    elif [[ $key == "" ]]; then
      echo ""
      break
    fi
  done

  ARROW_SELECTED=$selected
}

# Yes/No warning prompt
# Usage: warn_continue "Warning message"
# Exits on No
warn_continue() {
  local message="$1"
  echo ""
  echo "WARNING: $message"
  echo ""
  arrow_menu "Do you want to continue?" "(Y)es" "(N)o"
  if [ "$ARROW_SELECTED" -eq 1 ]; then
    echo "Exiting installer."
    exit 0
  fi
}

# ---------------------------------------------------
# Terminal picker
# ---------------------------------------------------
echo ""
echo "Which terminal emulator do you want?"
arrow_menu "Terminal:" "Kitty (default)" "Ghostty" "Alacritty"
case $ARROW_SELECTED in
  1) TERMINAL="ghostty" ;;
  2) TERMINAL="alacritty" ;;
  *) TERMINAL="kitty" ;;
esac
echo "  Selected: $TERMINAL"

# ---------------------------------------------------
# Browser picker
# ---------------------------------------------------
echo ""
echo "Which browser do you want?"
arrow_menu "Browser:" "Firefox (default)" "Chromium" "Zen (Flatpak)" "Brave"
case $ARROW_SELECTED in
  1) BROWSER="chromium"; BROWSER_PKG="chromium"; USE_FLATPAK_BROWSER=false ;;
  2) BROWSER="zen"; BROWSER_PKG="app.zen_browser.zen"; USE_FLATPAK_BROWSER=true ;;
  3) BROWSER="brave"; BROWSER_PKG="brave-browser"; USE_FLATPAK_BROWSER=false ;;
  *) BROWSER="firefox"; BROWSER_PKG="firefox"; USE_FLATPAK_BROWSER=false ;;
esac
echo "  Selected: $BROWSER"

# ---------------------------------------------------
# Detect distro family
# ---------------------------------------------------
echo ""
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
    warn_continue "ARCH IS NOT FULLY WORKING YET."
    echo "Installing packages..."
    yes | sudo pacman -S --needed \
      hyprland hyprpaper hypridle hyprlock waybar fuzzel \
      neovim git flatpak zsh starship eza zoxide \
      ttf-jetbrains-mono-nerd fastfetch

    # Terminal
    yes | sudo pacman -S --needed "$TERMINAL"

    # Browser
    if [ "$USE_FLATPAK_BROWSER" = true ]; then
      flatpak install flathub "$BROWSER_PKG" -y
    else
      yes | sudo pacman -S --needed "$BROWSER_PKG"
    fi
    ;;

  fedora)
    echo "Detected Fedora-based system."
    echo "Adding Copr repos..."
    for repo in hyprland waybar-hyprland hypridle hyprpaper hyprlock; do
      sudo dnf copr enable solopasha/$repo -y
    done
    echo "Installing packages..."
    sudo dnf install -y \
      hyprland hyprpaper hypridle hyprlock waybar fuzzel \
      neovim git flatpak zsh starship eza zoxide \
      jetbrains-mono-fonts-all fastfetch

    # Terminal
    sudo dnf install -y "$TERMINAL"

    # Browser
    if [ "$USE_FLATPAK_BROWSER" = true ]; then
      flatpak install flathub "$BROWSER_PKG" -y
    else
      sudo dnf install -y "$BROWSER_PKG"
    fi
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

# Copy standard config folders
for dir in fuzzel hypr nvim waybar; do
  if [ -d "$CONFIG_DIR/$dir" ]; then
    echo "  Backing up existing '$dir' to old-dots..."
    mv "$CONFIG_DIR/$dir" "$OLD_DOTS/$dir"
  fi
  echo "  Copying '$dir'..."
  cp -r "$REPO_CONF/$dir" "$CONFIG_DIR/$dir"
done

# Handle terminal config
if [ -d "$CONFIG_DIR/$TERMINAL" ]; then
  echo "  Backing up existing '$TERMINAL' config to old-dots..."
  mv "$CONFIG_DIR/$TERMINAL" "$OLD_DOTS/$TERMINAL"
fi
echo "  Copying '$TERMINAL' config..."
if [ -d "$REPO_CONF/$TERMINAL" ]; then
  cp -r "$REPO_CONF/$TERMINAL" "$CONFIG_DIR/$TERMINAL"
else
  echo "  (No separate config for $TERMINAL yet, using kitty config as fallback)"
  cp -r "$REPO_CONF/kitty" "$CONFIG_DIR/kitty"
fi

# ---------------------------------------------------
# .zshrc
# ---------------------------------------------------
echo "  Writing .zshrc..."
if [ -f "$HOME/.zshrc" ]; then
  echo "  Backing up existing .zshrc to old-dots..."
  cp "$HOME/.zshrc" "$OLD_DOTS/.zshrc"
fi

cat > "$HOME/.zshrc" << 'EOF'
# ~/.zshrc

# future me put some other useful stuff in here ok

n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; } # totally not stolen from omarchy
alias ls="eza --icons"
eval "$(zoxide init zsh --cmd cd)"

eval "$(starship init zsh)"
fastfetch
EOF

# ---------------------------------------------------
# Starship Catppuccin theme
# ---------------------------------------------------
echo "  Applying Starship Catppuccin Powerline theme..."
starship preset catppuccin-powerline -o "$CONFIG_DIR/starship.toml"

# ---------------------------------------------------
# Set zsh as default shell
# ---------------------------------------------------
echo "  Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "Cleaning up..."
rm -rf "$TMPDIR"

echo ""
echo "---------------------------------------------------"
echo "Dotfiles installed successfully!"
echo "  Terminal: $TERMINAL"
echo "  Browser:  $BROWSER"
echo "  Shell:    zsh (log out and back in to take effect)"
echo "Installation complete! You may now restart and launch Hyprland!"
echo "---------------------------------------------------"
