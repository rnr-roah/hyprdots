#!/bin/bash

DOTS="/home/roah/git-files/hyprdots"
BACKUP="$HOME/.config/backup"
STAMP="$(date +%Y%m%d_%H%M%S)"

configs=(
  hypr
  waybar
  swaync
  swayosd
  matugen
  alacritty
  kitty
  niri
  nvim
  fish
  nitch
  fastfetch
  btop
  cava
  rofi
  gtk-3.0
  gtk-4.0
)

echo "Creating backup folder..."
mkdir -p "$BACKUP"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/applications"

echo "Backing up existing configs and creating symlinks..."

for config in "${configs[@]}"; do
  source="$DOTS/.config/$config"
  target="$HOME/.config/$config"

  if [ ! -e "$source" ]; then
    echo "Skipping $config: source does not exist"
    continue
  fi

  if [ -L "$target" ]; then
    echo "Removing old symlink: $config"
    rm "$target"
  elif [ -e "$target" ]; then
    echo "Backing up existing config: $config"
    mv "$target" "$BACKUP/${config}_${STAMP}.bak"
  fi

  echo "Linking $config..."
  ln -s "$source" "$target"
done

echo "Handling Wallpapers..."

wall_source="$DOTS/Wallpapers"
wall_target="$HOME/Wallpapers"

if [ ! -e "$wall_source" ]; then
  echo "Skipping Wallpapers: source does not exist"
else
  if [ -L "$wall_target" ]; then
    echo "Removing old Wallpapers symlink"
    rm "$wall_target"
  elif [ -e "$wall_target" ]; then
    echo "Backing up existing Wallpapers folder"
    mv "$wall_target" "$BACKUP/Wallpapers_${STAMP}.bak"
  fi

  echo "Linking Wallpapers..."
  ln -s "$wall_source" "$wall_target"
fi

echo "Installing desktop entry..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/hyprdots.desktop" ]; then
  cp "$SCRIPT_DIR/hyprdots.desktop" "$HOME/.local/share/applications/"
elif [ -f "$DOTS/hyprdots.desktop" ]; then
  cp "$DOTS/hyprdots.desktop" "$HOME/.local/share/applications/"
else
  echo "Skipping desktop entry: hyprdots.desktop not found"
fi

echo "Done! All symlinks created."
echo "Old configs backed up to: $BACKUP"
