-- Converted from decoration.conf
-- Your old file had two decoration blocks. Hyprland merges later values over earlier ones,
-- so this keeps the final effective values from the second block.

hl.config({
  decoration = {
    rounding_power = 2.4,
    rounding = 18,

    blur = {
      enabled = true,
      xray = false,
      special = false,
      new_optimizations = true,
      size = 10,
      passes = 3,
      brightness = 1,
      noise = 0.05,
      contrast = 0.89,
      vibrancy = 0.5,
      vibrancy_darkness = 0.5,
      popups = false,
      popups_ignorealpha = 0.6,
      input_methods = true,
      input_methods_ignorealpha = 0.8,
    },

    shadow = {
      enabled = true,
      range = 50,
      offset = { 0, 4 },
      render_power = 10,
      color = "rgba(00000027)",
    },

    dim_inactive = true,
    dim_strength = 0.05,
    dim_special = 0.7,
  },
})
