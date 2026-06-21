-- Converted from layouts.conf
-- Fixed for Hyprland Lua 0.55+ workspace/layout API.

-- Workspace-specific layouts
hl.workspace_rule({ workspace = "1", layout = "scrolling" })

for i = 2, 9 do
  hl.workspace_rule({ workspace = tostring(i), layout = "dwindle" })
end

-- Old hyprlang:
-- workspace = special:minimized, gapsout:80, gapsin:20, bordersize:4, layoutopt:orientation:center
-- Lua uses layout_opts, not layoutopt.
hl.workspace_rule({
  workspace = "special:minimized",
  gaps_out = 80,
  gaps_in = 20,
  border_size = 4,
  layout_opts = {
    orientation = "center",
  },
})

-- Old hyprlang default workspace rule:
-- workspace = , gapsout:3, gapsin:2, , layoutopt:orientation:center
-- Lua needs an explicit selector; s[false] targets normal/non-special workspaces.
hl.workspace_rule({
  workspace = "s[false]",
  gaps_out = 3,
  gaps_in = 2,
  layout_opts = {
    orientation = "center",
  },
})

hl.config({
  dwindle = {
    preserve_split = true,
  },
})

hl.config({
  master = {
    -- Your old config had `new_on_active = true`, but Lua/current Hyprland expects
    -- a string: "before", "after", or "none". "after" is the closest useful match.
    new_on_active = "after",
  },
})

hl.config({
  gestures = {
    workspace_swipe_touch = true,
  },
})

hl.config({
  scrolling = {
    column_width = 0.95,
    focus_fit_method = 1,
    follow_focus = true,
    follow_min_visible = 1.0,
    explicit_column_widths = "0.334, 0.5, 0.667, 1.0",
    direction = "down",
  },
})

-- Placeholder for your old example device block.
-- Add real fields here after checking: hyprctl devices
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
