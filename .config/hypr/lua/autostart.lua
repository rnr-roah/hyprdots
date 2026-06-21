-- Converted from autostart.conf
-- hl.exec_cmd() is async, so trailing & is not needed.

hl.on("hyprland.start", function()
  hl.exec_cmd("pypr")
  hl.exec_cmd("hyprpm reload -n")
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 20")
  hl.exec_cmd("swaync")
  hl.exec_cmd("qs")

  hl.exec_cmd("~/.config/hypr/scripts/battery-watcher.sh")
  hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore.sh")

  hl.exec_cmd("hyprlock")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("kdeconnect-indicator")

  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
