-- Wezterm/wezterm.lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

-- Entrada y composición: Option compone y se desactivan dead keys
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.use_dead_keys = false

-- Tema por apariencia del sistema (Nightfox/Terafox) y ajustes de colores/blur
local function apply_theme_by_appearance()
	local appearance = wezterm.gui.get_appearance()
	local is_dark = appearance and appearance:find("Dark")

	if is_dark then
		config.color_scheme = "Nightfox"
		config.window_background_opacity = 0.96
		config.macos_window_background_blur = 0
		config.colors = config.colors or {}
		config.colors.foreground = "#eceff4"
		config.colors.selection_bg = "#3b4252"
		config.colors.selection_fg = "#eceff4"
	else
		config.color_scheme = "Terafox"
		config.window_background_opacity = 0.70
		config.macos_window_background_blur = 8
		config.colors = config.colors or {}
		config.colors.selection_bg = "#d8dee9"
		config.colors.selection_fg = "#2e3440"
	end
end

-- Fuente con fallback: Google Sans Code + MesloLGL Nerd Font
config.font = wezterm.font_with_fallback({
	{ family = "Google Sans Code", weight = "Medium" },
	{ family = "MesloLGL Nerd Font" },
})

-- Desactivar ligaduras
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Tamaño y espaciado
config.font_size = 12.0
config.line_height = 1.10
config.cell_width = 1.10

config.bold_brightens_ansi_colors = true
apply_theme_by_appearance()

-- Window decorations y padding
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
config.window_padding = { left = 16, right = 8, top = 24, bottom = 24 }

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 700
config.animation_fps = 60
config.cursor_thickness = 2
config.hide_mouse_cursor_when_typing = true

-- Abrir a pantalla completa del monitor activo
wezterm.on("gui-startup", function(cmd)
	local active = wezterm.gui.screens().active
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(active.x, active.y)
	window:gui_window():set_inner_size(active.width, active.height)
end)

-- Keybindings: todas en una sola tabla
local keys = {
	-- Tilde rápida con Option+n
	{ key = "n", mods = "OPT", action = action.SendString("~") },

	-- Alt/Option + Arrow: enviar la tecla con el modificador
	{ key = "UpArrow", mods = "ALT", action = action.SendKey({ key = "UpArrow", mods = "ALT" }) },
	{ key = "DownArrow", mods = "ALT", action = action.SendKey({ key = "DownArrow", mods = "ALT" }) },
	{ key = "LeftArrow", mods = "ALT", action = action.SendKey({ key = "LeftArrow", mods = "ALT" }) },
	{ key = "RightArrow", mods = "ALT", action = action.SendKey({ key = "RightArrow", mods = "ALT" }) },

	-- Option+Delete (Alt+Backspace): borrar palabra hacia atrás
	{ key = "Backspace", mods = "ALT", action = action.SendKey({ key = "Backspace", mods = "ALT" }) },

	-- Atajos existentes
	{ key = "d", mods = "CMD|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "k", mods = "CMD", action = action.ClearScrollback("ScrollbackAndViewport") },
	{ key = "w", mods = "CMD", action = action.CloseCurrentPane({ confirm = false }) },
	{ key = "w", mods = "CMD|SHIFT", action = action.CloseCurrentTab({ confirm = false }) },
	{ key = "LeftArrow", mods = "CMD", action = action.SendKey({ key = "Home" }) },
	{ key = "RightArrow", mods = "CMD", action = action.SendKey({ key = "End" }) },
	{ key = "p", mods = "CMD|SHIFT", action = action.ActivateCommandPalette },

	-- Abrir config con Zed
	{
		key = ",",
		mods = "CMD",
		action = action.SpawnCommandInNewTab({ cwd = wezterm.home_dir, args = { "zed", wezterm.config_file } }),
	},
	-- Alternativa absoluta (si Zed no está en PATH):
	-- {
	--   key = ",",
	--   mods = "CMD",
	--   action = action.SpawnCommandInNewTab({
	--     cwd = wezterm.home_dir,
	--     args = { "/Applications/Zed.app/Contents/MacOS/zed", wezterm.config_file },
	--   }),
	-- },
}

config.keys = keys

return config
