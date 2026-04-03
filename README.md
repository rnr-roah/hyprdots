# hyprdots 🌿

My personal Hyprland dotfiles for Arch Linux.

> Screenshots coming soon

---

## 📦 Configs Included

| Config | Description |
|--------|-------------|
| `hypr` | Hyprland, hyprlock, hypridle, hyprpaper |
| `waybar` | Status bar |
| `swaync` | Notification center |
| `swayosd` | OSD for volume/brightness |
| `matugen` | Material You color generation |
| `alacritty` | Terminal emulator |
| `kitty` | Terminal emulator |
| `ghostty` | Terminal emulator |
| `niri` | Scrollable tiling compositor config |
| `nvim` | Neovim (NvChad based) |
| `fish` | Fish shell |
| `nitch` | System info fetch |
| `fastfetch` | System info fetch |
| `btop` | Resource monitor |
| `cava` | Audio visualizer |
| `rofi` | App launcher |
| `gtk-3.0` | GTK3 theming |
| `gtk-4.0` | GTK4 theming |
| `wallpapers` | Wallpaper collection |

---

## 🔧 Dependencies

### Core
- [`hyprland`](https://hyprland.org/) — Wayland compositor
- [`waybar`](https://github.com/Alexays/Waybar) — Status bar
- [`swaync`](https://github.com/ErikReider/SwayNotificationCenter) — Notification daemon
- [`swayosd`](https://github.com/ErikReider/SwayOSD) — OSD
- [`matugen`](https://github.com/InioX/matugen) — Material You color generator
- [`hyprpaper`](https://github.com/hyprwg/hyprpaper) — Wallpaper daemon
- [`hypridle`](https://github.com/hyprwg/hypridle) — Idle daemon
- [`hyprlock`](https://github.com/hyprwg/hyprlock) — Screen locker
- [`uwsm`](https://github.com/Vladimir-csp/uwsm) — Session manager

### Terminal & Shell
- [`kitty`](https://sw.kovidgoyal.net/kitty/) / [`alacritty`](https://alacritty.org/) / [`ghostty`](https://ghostty.org/)
- [`fish`](https://fishshell.com/) — Shell
- [`starship`](https://starship.rs/) — Prompt
- [`neovim`](https://neovim.io/) — Editor

### Utilities
- [`rofi`](https://github.com/davatorium/rofi) — Launcher
- [`fuzzel`](https://codeberg.org/dnkl/fuzzel) — Launcher
- [`btop`](https://github.com/aristocratos/btop) — Resource monitor
- [`cava`](https://github.com/karlstav/cava) — Audio visualizer
- [`fastfetch`](https://github.com/fastfetch-cli/fastfetch) — System info
- [`grim`](https://sr.ht/~emersion/grim/) + [`slurp`](https://github.com/emersion/slurp) — Screenshots
- [`hyprshot`](https://github.com/Gustash/hyprshot) — Screenshot tool
- [`brightnessctl`](https://github.com/Hummer12007/brightnessctl) — Brightness control
- [`pamixer`](https://github.com/cdemoulins/pamixer) — Audio control
- [`pyprland`](https://github.com/hyprland-community/pyprland) — Hyprland plugin system

### Fonts
- `ttf-hack-nerd` — Main nerd font
- `ttf-nerd-fonts-symbols-mono`
- `noto-fonts-emoji`
- `woff2-font-awesome`

### Theming
- [`nwg-look`](https://github.com/nwg-piotr/nwg-look) — GTK settings
- `graphite-gtk-theme` — GTK theme
- `capitaine-cursors` — Cursor theme

---

## 🚀 Install

> ⚠️ Make sure you are on Arch Linux before proceeding.

### Step 1 — Install dependencies

```bash
git clone https://github.com/roah/hyprdots
cd hyprdots
chmod +x packages.sh
./packages.sh
```

This will:
- Install `yay` automatically if not already present
- Install all pacman and AUR packages needed for the rice

### Step 2 — Set up symlinks

```bash
chmod +x install.sh
./install.sh
```

This will:
- Back up any existing configs to `~/.config/backup/`
- Create symlinks from `~/.config` to this repo

---

## 📁 Structure

```
hyprdots/
├── .config/
│   ├── hypr/
│   ├── waybar/
│   ├── swaync/
│   └── ...
├── wallpapers/
├── install.sh
├── packages.sh
└── README.md
```
