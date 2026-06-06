#!/usr/bin/env bash
set -euo pipefail

if ! sudo -v; then
  echo "Sudo authentication failed."
  exit 1
fi

while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

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

link_item() {
  local source="$1"
  local target="$2"
  local name="$3"

  if [ ! -e "$source" ]; then
    echo "Skipping $name: source does not exist"
    return
  fi

  if [ -L "$target" ]; then
    echo "Removing old symlink: $target"
    rm -f "$target"
  elif [ -e "$target" ]; then
    echo "Backing up existing: $target"
    mv "$target" "$BACKUP/${name}.bak"
  fi

  echo "Linking $name..."
  ln -s "$source" "$target"
}

echo "Dotfiles repo: $DOTS"
echo "Backup folder: $BACKUP"

mkdir -p "$BACKUP"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/applications"

echo "Running packages.sh..."

if [ -f "$DOTS/packages.sh" ]; then
  chmod +x "$DOTS/packages.sh"
  "$DOTS/packages.sh"
else
  echo "Skipping packages.sh: file not found"
fi

echo "Linking configs..."

for config in "${configs[@]}"; do
  link_item \
    "$DOTS/.config/$config" \
    "$HOME/.config/$config" \
    "$config"
done

echo "Linking Wallpapers..."

link_item \
  "$DOTS/wallpapers" \
  "$HOME/Wallpapers" \
  "Wallpapers"

echo "Installing desktop entry..."

if [ -f "$DOTS/hyprdots.desktop" ]; then
  cp "$DOTS/hyprdots.desktop" "$HOME/.local/share/applications/"
else
  echo "Skipping desktop entry: hyprdots.desktop not found"
fi

echo "Done."
echo "Old configs backed up to: $BACKUP"
