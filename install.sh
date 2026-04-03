#!/bin/bash

DOTS="/home/roah/git-files/hyprdots"
BACKUP="$HOME/.config/backup"

echo "Creating backup folder..."
mkdir -p "$BACKUP"

echo "Backing up existing configs..."
configs=(hypr waybar swaync swayosd matugen alacritty kitty niri nvim fish nitch fastfetch btop cava rofi gtk-3.0 gtk-4.0)

for config in "${configs[@]}"; do
    if [ -e "$HOME/.config/$config" ] && [ ! -L "$HOME/.config/$config" ]; then
        echo "  Backing up $config..."
        mv "$HOME/.config/$config" "$BACKUP/$config.bak"
    fi
done

# Backup wallpapers
if [ -e "$HOME/Wallpapers" ] && [ ! -L "$HOME/Wallpapers" ]; then
    echo "  Backing up Wallpapers..."
    mv "$HOME/Wallpapers" "$BACKUP/Wallpapers.bak"
fi

echo "Creating symlinks..."
for config in "${configs[@]}"; do
    ln -sf "$DOTS/.config/$config" "$HOME/.config/$config"
done

ln -sf "$DOTS/wallpapers" "$HOME/Wallpapers"

echo "Done! All symlinks created."
echo "Old configs backed up to $BACKUP"
