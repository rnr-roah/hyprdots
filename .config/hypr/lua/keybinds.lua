-- Converted from keybinds.conf

local mainMod = "SUPER"

local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

local function raw_dispatch(dispatcher, args)
  args = args or ""
  return exec("hyprctl dispatch " .. dispatcher .. (args ~= "" and (" " .. args) or ""))
end

local function both(...)
  local actions = { ... }
  return function()
    for _, action in ipairs(actions) do
      hl.dispatch(action)
    end
  end
end




-- Gaming submap toggle
-- This matches your old Hyprlang behavior more closely:
-- ALT+G only runs your existing script, and the script should decide whether
-- to enter/exit the gaming submap.
--
-- IMPORTANT for Lua Hyprland:
-- inside ~/.config/hypr/scripts/keybinds.sh, use:
--   hyprctl dispatch 'hl.dsp.submap("gaming")'
--   hyprctl dispatch 'hl.dsp.submap("reset")'
-- instead of the old:
--   hyprctl dispatch submap gaming/reset
hl.bind("ALT + G", exec("~/.config/hypr/scripts/keybinds.sh"))

hl.define_submap("gaming", function()
  -- Same key while inside game mode: let your script toggle back out.
  hl.bind("ALT + G", exec("~/.config/hypr/scripts/keybinds.sh"))

  -- These were the only binds active in your old gaming submap.
  hl.bind("Home", hl.dsp.focus({ workspace = "1" }))
  hl.bind("End", hl.dsp.focus({ workspace = "2" }))

  -- Emergency exit so you do not get trapped in the submap.
  --hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("ALT + SHIFT + G", exec("~/.config/hypr/scripts/gamemode.sh"))
hl.bind("ALT + CONTROL + G", exec("~/.config/hypr/scripts/normal-mode.sh"))

-- Wallpaper / helper binds
hl.bind("ALT + W", exec("~/.config/hypr/scripts/static-paper.sh"))
hl.bind("ALT + L", exec("~/.config/hypr/scripts/live-paper.sh"))
hl.bind("ALT + SHIFT + L", exec("~/.config/hypr/scripts/live-paper-pingpong.sh"))
hl.bind("ALT + C", exec("wayscriber -a"))

hl.bind("SUPER + V", exec([[cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy]]))
hl.bind("ALT + TAB", raw_dispatch("scrolloverview:overview", "toggle"))

hl.bind("SUPER + M", exec("~/.config/hypr/scripts/minimize.sh"))
hl.bind("SUPER + TAB", exec("~/.config/hypr/scripts/maximize.sh"))
hl.bind("SUPER + TAB", hl.dsp.submap("minimized"))

hl.define_submap("minimized", function()
  hl.bind("mouse:272", both(exec("~/.config/hypr/scripts/restore-on-click.sh"), hl.dsp.submap("reset")))
  hl.bind("SUPER + TAB", both(exec("~/.config/hypr/scripts/maximize.sh"), hl.dsp.submap("reset")))
  hl.bind("escape", both(exec("~/.config/hypr/scripts/maximize.sh"), hl.dsp.submap("reset")))
end)

hl.bind("SUPER + F9", exec("~/.config/hypr/scripts/keyboard-auto-toggle.sh"))
-- Duplicate SUPER+TAB from your old file, preserved.
hl.bind("SUPER + TAB", exec("qs ipc -p /usr/share/tide-island call overview toggle"))

hl.bind(mainMod .. " + SHIFT + H", exec("~/.config/hypr/scripts/hotspot.sh"))
hl.bind(mainMod .. " + SHIFT + Tab", exec("~/.config/hypr/scripts/layouts.sh"))
hl.bind(mainMod .. " + Return", exec("kitty"))
hl.bind(mainMod .. " + SHIFT + N", exec("swaync-client -t"))
hl.bind(mainMod .. " + L", exec("hyprlock"))
hl.bind(mainMod .. " + SHIFT + C", exec([[COLOR="$(hyprpicker -r)"; echo -n "$COLOR" | wl-copy; notify-send "Picked Color" "$COLOR"]]))
hl.bind(mainMod .. " + B", exec("zen-browser"))
hl.bind(mainMod .. " + SHIFT + B", exec("chromium"))
hl.bind(mainMod .. " + R", exec("nautilus"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("ALT + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Space", exec("~/.config/hypr/scripts/toggleallfloat.sh"))
hl.bind("CONTROL + SHIFT + Escape", exec("kitty -e htop"))
hl.bind("ALT + Space", exec([[rofi -show drun -display-drun "   "]]))
hl.bind("ALT + SHIFT + W", exec("~/.config/hypr/wallpaper-restore.sh; hyprctl reload; pkill waybar; waybar"))
hl.bind("ALT + CONTROL + W", exec("~/.config/waybar/scripts/waybar_switcher.sh"))

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- Removed: master-only layoutmsg. It errors on scrolling workspaces.
-- hl.bind(mainMod .. " + S", hl.dsp.layout("swapwithmaster master"))
-- Removed: master/dwindle-only layoutmsg. It errors on scrolling workspaces.
-- hl.bind(mainMod .. " + D", hl.dsp.layout("cyclenext"))
-- Removed: master/dwindle-only layoutmsg. It errors on scrolling workspaces.
-- hl.bind(mainMod .. " + A", hl.dsp.layout("cycleprev"))

hl.bind(mainMod .. " + SHIFT + P", exec([[alacritty -e shut-down class 'shutdown']]))
hl.bind(mainMod .. " + SHIFT + E", exec("kitty -e sudo vim /home/roah/.config/hypr/lua/"))
hl.bind(mainMod .. " + C", exec("bash /home/roah/.config/scripts/screenrecorder.sh"))

-- Pyprland scratchpads
hl.bind(mainMod .. " + SHIFT + Return", exec("pypr toggle alacritty && hyprctl dispatch bringactivetotop"))
hl.bind(mainMod .. " + SHIFT + H", exec("pypr toggle claude && hyprctl dispatch bringactivetotop"))
hl.bind(mainMod .. " + SHIFT + R", exec("pypr toggle ranger && hyprctl dispatch bringactivetotop"))
hl.bind("ALT + SHIFT + S", exec("pypr toggle pavucontrol && hyprctl dispatch bringactivetotop"))
hl.bind(mainMod .. " + N", exec("pypr toggle micro && hyprctl dispatch bringactivetotop"))
hl.bind(mainMod .. " + G", exec("pypr toggle google && hyprctl dispatch bringactivetotop"))
hl.bind(mainMod .. " + SHIFT + M", exec("pypr toggle whatsapp && hyprctl dispatch bringactivetotop"))

-- Move focus
hl.bind(mainMod .. " + A", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + D", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + W", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + S", hl.dsp.focus({ direction = "d" }))

-- Resize active window
hl.bind(mainMod .. " + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(mainMod .. " + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(mainMod .. " + up", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))
hl.bind(mainMod .. " + down", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ direction = "d" }))

-- Workspaces and move-to-workspace
for i = 1, 10 do
  local key = tostring(i % 10)
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Optional scrolling-layout movement. These match Hyprland scrolling layout messages.
-- They avoid SUPER+A/D/S because those are already your normal focus keys.
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse and side buttons
--hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
--hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
--hl.bind("mouse:276", hl.dsp.window.drag(), { mouse = true })
--hl.bind("mouse:275", hl.dsp.window.resize(), { mouse = true })

-- Screenshots / recorder. Note: your old file has SUPER+C twice; both are preserved.
hl.bind(mainMod .. " + C", exec("hyprshot -z -m region --clipboard-only"))
hl.bind(mainMod .. " + Print", exec("hyprshot -m region -o ~/screenshots"))
hl.bind("Print", exec("hyprshot -z -m output -m active -o ~/screenshots"))
hl.bind(mainMod .. " + F12", exec("hyprshot -z -m region -o ~/screenshots"))
hl.bind(mainMod .. " + H", exec("~/.config/hypr/scripts/show-keybinds.sh"))
hl.bind("F12", exec("hyprshot -m output -m active -o ~/screenshots"))

-- Brightness
hl.bind("XF86MonBrightnessUp", exec("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("F4", exec("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("F3", exec("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ & canberra-gtk-play -i audio-volume-change"), { locked = true, repeating = true })

hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- & canberra-gtk-play -i audio-volume-change"), { locked = true, repeating = true })

hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & canberra-gtk-play -i audio-volume-change"), { locked = true })

hl.bind("F8", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ & canberra-gtk-play -i audio-volume-change"), { locked = true, repeating = true })

hl.bind("F7", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- & canberra-gtk-play -i audio-volume-change"), { locked = true, repeating = true })

hl.bind("F6", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & canberra-gtk-play -i audio-volume-change"), { locked = true })

-- Emoji
hl.bind("F2", exec("rofi -show emoji -modi emoji"))
hl.bind("SUPER + period", exec("rofi -show emoji -modi emoji"))

-- Mic
hl.bind("XF86AudioMicMute", exec("swayosd-client --input-volume=mute-toggle & canberra-gtk-play -i audio-volume-change"), { locked = true })
hl.bind("F9", exec("swayosd-client --input-volume=mute-toggle & canberra-gtk-play -i audio-volume-change"), { locked = true })

-- Playerctl
hl.bind("XF86AudioPlay", exec("swayosd-client --playerctl=play-pause"), { locked = true })
hl.bind("F10", exec("swayosd-client --playerctl=play-pause"), { locked = true })

-- Copilot key / AI scratchpads
--hl.bind(mainMod .. " + SHIFT + F23", exec([[bash -c 'pkill -f ~/.config/roah-voice/kiro.sh; ~/.config/roah-voice/kiro.sh']]))
--hl.bind("SUPER + SHIFT + ALT + F23", exec("pypr toggle chatgpt && hyprctl dispatch bringactivetotop"))
--hl.bind("SUPER + Z", exec("pypr toggle gemini && hyprctl dispatch bringactivetotop"))
--hl.bind("SUPER + SHIFT + CONTROL + Control_R", exec([[notify-send "Copilot" "Caught you."]]), { release = true })

-- Pinning / centering
hl.bind("ALT + C", hl.dsp.window.center())
hl.bind("ALT + P", hl.dsp.window.pin())
