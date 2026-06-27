-- Converted from general.conf

local colors = require("lua.colors")

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 4,
    border_size = 2,
    layout = "dwindle",
    allow_tearing = false,
    col = {
      active_border = colors.primary,
      inactive_border = colors.on_primary,
    },
  },

  misc = {
    background_color = "rgba(161311FF)",
    disable_hyprland_logo = true,
    -- Your old config had true. If Hyprland complains, change this to 0.
    force_default_wallpaper = true,
  },
})

-- Plugin config is the one part most likely to need a tiny manual tweak,
-- because third-party plugins may not expose perfect typed Lua fields yet.
-- These runtime keywords preserve your old plugin settings as closely as possible.
local function keyword(k, v)
  hl.exec_cmd("hyprctl keyword " .. k .. " " .. string.format("%q", v))
end

hl.on("hyprland.start", function()
  -- hyprbars
  keyword("plugin:hyprbars:bar_text_font", "Google Sans Flex Medium, Rubik, Geist, AR One Sans, Reddit Sans, Inter, Roboto, Ubuntu, Noto Sans, sans-serif")
  keyword("plugin:hyprbars:bar_height", "30")
  keyword("plugin:hyprbars:bar_padding", "10")
  keyword("plugin:hyprbars:bar_button_padding", "5")
  keyword("plugin:hyprbars:bar_precedence_over_border", "true")
  keyword("plugin:hyprbars:bar_part_of_window", "true")
  keyword("plugin:hyprbars:bar_color", "rgba(161311FF)")
  keyword("plugin:hyprbars:col.text", "rgba(e9e1deFF)")
  keyword("plugin:hyprbars:hyprbars-button", "rgb(e9e1de), 13, 󰖭, hyprctl dispatch killactive")
  keyword("plugin:hyprbars:hyprbars-button", "rgb(e9e1de), 13, 󰖯, hyprctl dispatch fullscreen 1")
  keyword("plugin:hyprbars:hyprbars-button", "rgb(e9e1de), 13, 󰖰, hyprctl dispatch movetoworkspacesilent special")

  -- hyprgrass / touch_gestures
  keyword("plugin:touch_gestures:long_press_delay", "300")
  keyword("plugin:touch_gestures:hyprgrass-bindm", ", longpress:2, movewindow")
  keyword("plugin:touch_gestures:hyprgrass-bindm", ", longpress:3, resizewindow")

  -- scrolloverview plugin
  keyword("plugin:scrolloverview:gesture_distance", "300")
  keyword("plugin:scrolloverview:scale", "0.5")
  keyword("plugin:scrolloverview:workspace_gap", "100")
  keyword("plugin:scrolloverview:wallpaper", "0")
  keyword("plugin:scrolloverview:blur", "false")
  keyword("plugin:scrolloverview:shadow:enabled", "false")
  keyword("plugin:scrolloverview:shadow:range", "50")
  keyword("plugin:scrolloverview:shadow:render_power", "3")
  keyword("plugin:scrolloverview:shadow:color", "rgba(1a1a1aee)")
end)
