-- Roah's Hyprland Lua config - first migration pass
-- Place this file at: ~/.config/hypr/hyprland.lua
-- Place the lua/ folder next to it: ~/.config/hypr/lua/
--
-- Hyprland 0.55+ loads hyprland.lua instead of hyprland.conf when this file exists.

require("lua.colors")
require("lua.monitors")
require("lua.input")
require("lua.hyprland-gui")
require("lua.general")
require("lua.decoration")
require("lua.animations")
require("lua.layouts")
require("lua.rules")
require("lua.autostart")
require("lua.keybinds")

pcall(dofile, os.getenv("HOME") .. "/.config/hypr/lua/state/laptop-keyboard.lua")
