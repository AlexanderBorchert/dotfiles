local wezterm = require("wezterm")

local config = {

	-- default_domain = "WSL:Ubuntu-24.04",

	leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 },

	color_scheme = "Google Light (base16)",
	font = wezterm.font("JetBrainsMono Nerd Font"),

	-- Start in fullscreen
	initial_cols = 120,
	initial_rows = 30,
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },

	-- -- Disable tab bar for minimal UI
	-- enable_tab_bar = false,

	-- Window decorations (just allow resizing)
	window_decorations = "RESIZE",

	keys = {

		{ key = "F11", action = wezterm.action.ToggleFullScreen },
		{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
		-- Split management
		{
			key = "v",
			mods = "LEADER",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "h",
			mods = "LEADER",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		-- Tab management
		{
			key = "c",
			mods = "LEADER",
			action = wezterm.action.SpawnTab("CurrentPaneDomain"),
		},
		{
			key = "p",
			mods = "LEADER",
			action = wezterm.action.ActivateTabRelative(-1),
		},
		{
			key = "n",
			mods = "LEADER",
			action = wezterm.action.ActivateTabRelative(1),
		},
		-- Pane navigation with Ctrl + h/j/k/l
		{ key = "h", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
		{ key = "l", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Right") },
		{ key = "k", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
		{ key = "j", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Down") },

		-- Workspaces
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action.ShowLauncherArgs({
				flags = "WORKSPACES",
			}),
		},
		--Adjust panes
		{
			key = "h",
			mods = "CTRL|SHIFT",
			action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
		},
		{
			key = "l",
			mods = "CTRL|SHIFT",
			action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
		},
		{
			key = "j",
			mods = "CTRL|SHIFT",
			action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
		},
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
		},
		{
			key = "m",
			mods = "LEADER",
			action = wezterm.action.TogglePaneZoomState,
		},
	},
}

if os.getenv('WSL_DISTRO_NAME') then
  config.default_domain = 'WSL:' .. os.getenv('WSL_DISTRO_NAME')
end

-- Add LEADER + number to switch to tab 1-9
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
