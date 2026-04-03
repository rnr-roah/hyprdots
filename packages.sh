#!/bin/bash

# ─────────────────────────────────────────
#  hyprdots - packages.sh
#  Install all dependencies for the rice
# ─────────────────────────────────────────

# Install yay if not already installed
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# ── Core / Hyprland ───────────────────────
sudo pacman -S --noconfirm --needed \
    hyprland \
    hyprlock \
    hyprpaper \
    hypridle \
    hyprshot \
    hyprpicker \
    hyprsunset \
    xdg-desktop-portal-hyprland \
    uwsm \
    xwayland-satellite

# ── Status Bar & Notifications ────────────
sudo pacman -S --noconfirm --needed \
    waybar \
    swaync \
    swayosd \
    swaybg

# ── Launchers ─────────────────────────────
sudo pacman -S --noconfirm --needed \
    rofi \
    fuzzel \
    tofi \
    wofi

# ── Terminals ─────────────────────────────
sudo pacman -S --noconfirm --needed \
    alacritty \
    kitty \
    ghostty

# ── Shell & Prompt ────────────────────────
sudo pacman -S --noconfirm --needed \
    fish \
    starship \
    tmux \
    fzf

# ── Editor ────────────────────────────────
sudo pacman -S --noconfirm --needed \
    neovim

# ── Fonts ─────────────────────────────────
sudo pacman -S --noconfirm --needed \
    ttf-hack-nerd \
    ttf-nerd-fonts-symbols-mono \
    noto-fonts-emoji \
    woff2-font-awesome

# ── Theming ───────────────────────────────
sudo pacman -S --noconfirm --needed \
    nwg-look \
    graphite-gtk-theme \
    capitaine-cursors \
    matugen

# ── System Utilities ──────────────────────
sudo pacman -S --noconfirm --needed \
    brightnessctl \
    pamixer \
    pavucontrol \
    playerctl \
    power-profiles-daemon \
    networkmanager \
    network-manager-applet \
    blueman \
    bluez \
    bluez-utils \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    wireplumber \
    polkit-gnome \
    grim \
    slurp \
    wl-clipboard \
    cliphist \
    wtype \
    keyd \
    gamemode

# ── File Manager & Viewers ────────────────
sudo pacman -S --noconfirm --needed \
    nautilus \
    ranger \
    yazi \
    imv \
    loupe \
    mpv

# ── Monitoring & Info ─────────────────────
sudo pacman -S --noconfirm --needed \
    btop \
    htop \
    cava \
    fastfetch \
    neofetch

# ── Screenshot & Recording ────────────────
sudo pacman -S --noconfirm --needed \
    gpu-screen-recorder \
    obs-studio \
    wf-recorder

# ── Misc ──────────────────────────────────
sudo pacman -S --noconfirm --needed \
    git \
    feh \
    micro \
    kdeconnect \
    localsend \
    swayidle

# ── AUR Packages ──────────────────────────
yay -S --noconfirm --needed \
    swaync \
    swayosd \
    matugen \
    pyprland \
    hyprpanel \
    nitch \
    innu-git \
    sddm-theme-corners-git \
    vencord-git \
    gpu-screen-recorder-ui \
    nwg-displays \
    battery-notify \
    rofi-emoji \
    rofi-calc \
    localsend-bin \
    sunsetr \
    awww

echo ""
echo "All packages installed!"
echo "Now run ./install.sh to set up symlinks."
