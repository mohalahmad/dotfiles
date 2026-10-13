local wezterm = require("wezterm")
local act = wezterm.action

return {
	font = wezterm.font_with_fallback({
		"JetBrainsMonoNL Nerd Font Mono",
		"JetBrains Mono",
	}),
	font_size = 12.0,
	line_height = 1.2,
	adjust_window_size_when_changing_font_size = false,

	color_scheme = "Nord (Gogh)",

	window_background_opacity = 0.94,
	window_decorations = "RESIZE",
	window_padding = { left = 14, right = 14, top = 10, bottom = 10 },
	macos_window_background_blur = 40,

	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	hide_tab_bar_if_only_one_tab = true,
	tab_max_width = 32,

	default_cursor_style = "BlinkingBlock",
	cursor_blink_rate = 600,

	scrollback_lines = 10000,

	max_fps = 120,

	keys = {
		{ key = "t", mods = "CTRL", action = act.ToggleFullScreen },
		{ key = "'", mods = "CTRL", action = act.ClearScrollback("ScrollbackAndViewport") },
		-- split
		{ key = "Space", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "Enter", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		-- navigation
		{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
		{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
		{ key = "UpArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
		{ key = "DownArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
		-- pane control
		{ key = "x", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
		-- pane resize
		{ key = "a", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
		{ key = "d", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
		{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
		{ key = "s", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
		-- copy mode
		{ key = "e", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
		-- tabs
		{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "q", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	},

	mouse_bindings = {
		{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
	},

	check_for_updates = false,
	audible_bell = "Disabled",
	color_scheme_dirs = {},
	enable_wayland = true,
}
