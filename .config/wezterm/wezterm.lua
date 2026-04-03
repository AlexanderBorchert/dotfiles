local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- --------------------------------------------------------------------
-- 1. General & UI Settings
-- --------------------------------------------------------------------
config.color_scheme = "Google Light (base16)"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.initial_cols = 120
config.initial_rows = 30
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = "RESIZE"

-- Tab Bar Styling
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.colors = {
	tab_bar = {
		background = "#ffffff",
		active_tab = { bg_color = "#d9f9ff", fg_color = "#000000", intensity = "Bold" },
		inactive_tab = { bg_color = "#ffffff", fg_color = "#888888" },
	},
}

-- --------------------------------------------------------------------
-- 2. Environment & Shell
-- --------------------------------------------------------------------
config.default_prog = { "fish", "-l" }

if os.getenv("WSL_DISTRO_NAME") then
	config.default_domain = "WSL:" .. os.getenv("WSL_DISTRO_NAME")
end

-- --------------------------------------------------------------------
-- 3. Keybindings
-- --------------------------------------------------------------------
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{ key = "F11", action = act.ToggleFullScreen },
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "m", mods = "LEADER", action = act.TogglePaneZoomState },

	-- Splits & Tabs
	{ key = "v", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },

	-- Navigation (Ctrl + hjkl)
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },

	-- Resizing (Ctrl + Shift + hjkl)
	{ key = "h", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "l", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "j", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "k", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },

	{
		key = "w",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "workspaces",
			one_shot = true, -- Automatically exit table after one action
		}),
	},
	{
		key = "t",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "tabs",
			one_shot = true,
		}),
	},
}

config.key_tables = {
	workspaces = {
		-- 'w' to view/switch workspaces
		{
			key = "w",
			action = act.ShowLauncherArgs({
				flags = "WORKSPACES",
				title = "🚀 Workspace auswählen",
				help_text = "",
			}),
		},
		-- 'c' to create a new workspace
		{
			key = "c",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
					end
				end),
			}),
		},

		-- 'r' to rename current workspace
		{
			key = "r",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Aqua" } },
					{ Text = "Rename current workspace to:" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(window:active_workspace(), line)
					end
				end),
			}),
		},

		-- Escape to cancel
		{ key = "Escape", action = "PopKeyTable" },
	},
	tabs = {
		-- 'c' to create a new tab
		{ key = "c", action = act.SpawnTab("CurrentPaneDomain") },

		-- 'x' to close (kill) the current tab
		{
			key = "x",
			action = act.CloseCurrentTab({ confirm = true }),
		},

		-- 'r' to rename the current tab
		{
			key = "r",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Yellow" } },
					{ Text = "Rename tab to:" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},

		-- 'l' to list tabs (launcher)
		{
			key = "l",
			action = act.ShowLauncherArgs({ flags = "TABS" }),
		},
	},
}

-- Quick Tab Access (Leader + 1-9)
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

-- --------------------------------------------------------------------
-- 4. Custom Tab Titles & Icons
-- --------------------------------------------------------------------
local process_icons = {
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["nvim"] = wezterm.nerdfonts.custom_neovim,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["node"] = wezterm.nerdfonts.mdi_nodejs,
	["python"] = wezterm.nerdfonts.dev_python,
	["git"] = wezterm.nerdfonts.dev_git,
	["ssh"] = wezterm.nerdfonts.fa_server,
	["sudo"] = wezterm.nerdfonts.fa_unlock_alt,
}

wezterm.on("format-tab-title", function(tab)
	local pane = tab.active_pane
	local name = string.gsub(pane.foreground_process_name, "(.*[/\\\\])(.*)", "%2")
	local icon = process_icons[name] or wezterm.nerdfonts.cod_terminal
	return string.format(" %s %s ", icon, name)
end)

-- --------------------------------------------------------------------
-- 5. Startup Events
-- --------------------------------------------------------------------
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

return config
