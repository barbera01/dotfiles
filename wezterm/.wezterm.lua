local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font("MesloLGLDZ Nerd Font", { weight = "Regular" })
config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font("MesloLGLDZ Nerd Font", { weight = "Bold" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font("MesloLGLDZ Nerd Font", { style = "Italic" }),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font("MesloLGLDZ Nerd Font", { weight = "Bold", style = "Italic" }),
	},
}
config.font_size = 14.0
config.cell_width = 1.0
config.line_height = 1.0

-- Window configuration
config.window_background_opacity = 0.85
config.window_decorations = "RESIZE" -- closest to "buttonless"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.initial_cols = 250
config.initial_rows = 58

-- Colors
config.colors = {
	background = "#000000",
	foreground = "#abb2bf",
	cursor_bg = "#528bff",
	cursor_fg = "#282c34",
	cursor_border = "#528bff",
}

-- Scrolling
config.scrollback_lines = 1000

-- Mouse
config.hide_mouse_cursor_when_typing = true

-- Environment / Terminal
config.term = "xterm-256color"

-- Disable tab bar for cleaner look (optional, uncomment if desired)
-- config.enable_tab_bar = false

return config
