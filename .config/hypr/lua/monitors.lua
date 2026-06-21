-- Converted from monitors.conf

hl.monitor({
  output = "eDP-1",
  mode = "2880x1800@120",
  position = "0x0",
  scale = 1.50,
})

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  misc = {
    -- Variable refresh rate. Your old value was: misc:vrr = 2
    vrr = 2,
  },
})
