-- Converted from rules.conf

-- hyprdots GUI
hl.window_rule({ match = { class = "^hyprdots$" }, float = true })
hl.window_rule({ match = { class = "^hyprdots$" }, size = { 900, 750 } })
hl.window_rule({ match = { class = "^hyprdots$" }, center = true })

-- scrcpy
hl.window_rule({ match = { class = "^scrcpy$" }, float = true })
hl.window_rule({ match = { class = "^scrcpy$" }, size = { 340, 750 } })
hl.window_rule({ match = { class = "^scrcpy$" }, move = { 55, 200 } })

-- Layer rules
hl.layer_rule({ match = { namespace = "^rofi$" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "^swaync-control-center$" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "^rofi$" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0 })

hl.layer_rule({ match = { namespace = "^qs-music-popup$" }, blur = true })
hl.layer_rule({ match = { namespace = "qs-music-popup" }, ignore_alpha = 0 })

hl.animation({ leaf = "layers", enabled = true, speed = 0.5, bezier = "default", style = "slide" })

hl.layer_rule({ match = { namespace = "^swaync-control-center$" }, blur = true })
hl.layer_rule({ match = { namespace = "^swaync-notification-window$" }, blur = true })
hl.layer_rule({ match = { namespace = "^swaync-control-center$" }, ignore_alpha = 0.0 })
hl.layer_rule({ match = { namespace = "^swaync-notification-window$" }, ignore_alpha = 0.0 })

-- Your old rule denied screencopy globally.
-- This requires a restart after changing permissions.
hl.permission({ binary = ".*", type = "screencopy", mode = "deny" })

-- Floating scratchpads / utility apps
local floatClasses = {
  "^Alacritty$",
  "^feh$",
  "^mpv$",
  "^it.mijorus.smile$",
  "^chrome-google.com__-Default$",
  "^chrome-claude.com__-Default$",
  "^chrome-chatgpt.com__-Default$",
  "^chrome-gemini.google.com__-Default$",
  "^chrome-web.whatsapp.com__-Default$",
  "^org.pulseaudio.pavucontrol$",
  "^micro$",
  "^scratchpad$",
}

for _, class in ipairs(floatClasses) do
  hl.window_rule({ match = { class = class }, float = true })
end

-- Workspace/game rules
hl.window_rule({ match = { class = "^Gamescope$" }, workspace = "2" })
hl.window_rule({ match = { title = "^Steam$" }, workspace = "3" })
hl.window_rule({ match = { title = "^steam$" }, workspace = "3" })
hl.window_rule({ match = { class = "^Steam$" }, workspace = "3" })
hl.window_rule({ match = { class = "^steam$" }, workspace = "3" })

hl.window_rule({ match = { class = "^genshinimpact.exe$" }, workspace = "3" })
hl.window_rule({ match = { class = "^genshinimpact.exe$" }, fullscreen = true })

hl.window_rule({ match = { class = "^steam_app_2073850$" }, workspace = "2" }) -- THE FINALS
hl.window_rule({ match = { class = "^steam_app_2073850$" }, tile = true })
hl.window_rule({ match = { class = "^steam_app_2073850$" }, fullscreen = true })
hl.window_rule({ match = { title = "^THE FINALS$" }, workspace = "2" })
hl.window_rule({ match = { class = "^steam_app_2073850$" }, immediate = true })
