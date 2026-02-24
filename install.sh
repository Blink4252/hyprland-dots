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
 
  ;;

fedora)
  echo "Detected Fedora-based system."

  echo "Adding Copr repos…"
 
  echo "Installing packages…"
  
  ;;

deb)
  echo "DISTRO NOT SUPPORTED. TRY USING ARCH OR FEDORA."
  exit 1
  ;;

*)
  echo "UNKNOWN DISTRO — TRY USING ARCH OR FEDORA."
  exit 1
  ;;
esac
