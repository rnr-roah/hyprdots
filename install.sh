#!/bin/bash

DOTS="/home/roah/git-files/hyprdots"

echo "Creating symlinks..."

# Configs
ln -sf "$DOTS/.config/hypr"       ~/.config/hypr
ln -sf "$DOTS/.config/waybar"     ~/.config/waybar
ln -sf "$DOTS/.config/swaync"     ~/.config/swaync
ln -sf "$DOTS/.config/swayosd"    ~/.config/swayosd
ln -sf "$DOTS/.config/matugen"    ~/.config/matugen
ln -sf "$DOTS/.config/alacritty"  ~/.config/alacritty
ln -sf "$DOTS/.config/kitty"      ~/.config/kitty
ln -sf "$DOTS/.config/niri"       ~/.config/niri
ln -sf "$DOTS/.config/nvim"       ~/.config/nvim
ln -sf "$DOTS/.config/fish"       ~/.config/fish
ln -sf "$DOTS/.config/nitch"      ~/.config/nitch
ln -sf "$DOTS/.config/fastfetch"  ~/.config/fastfetch
ln -sf "$DOTS/.config/btop"       ~/.config/btop
ln -sf "$DOTS/.config/cava"       ~/.config/cava
ln -sf "$DOTS/.config/rofi"       ~/.config/rofi
ln -sf "$DOTS/.config/gtk-3.0"    ~/.config/gtk-3.0
ln -sf "$DOTS/.config/gtk-4.0"    ~/.config/gtk-4.0

# Wallpapers
ln -sf "$DOTS/wallpapers"         ~/Wallpapers

echo "Done! All symlinks created."
