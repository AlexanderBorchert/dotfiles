local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- --------------------------------------------------------------------
-- 1. General & UI Settings
-- --------------------------------------------------------------------
config.color_scheme = "Google Light (base16)"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = "RESIZE"

-- Tab Bar Styling
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

config.window_frame = {
	-- Steuert die Hintergrundfarbe des Balkens hinter/neben den Tabs
	active_titlebar_bg = "#ffffff",
	inactive_titlebar_bg = "#ffffff",
}

config.colors = {
	tab_bar = {
		background = "#ffffff",
		-- Entfernt die graue Linie/Kante bei inaktiven Tabs
		inactive_tab_edge = "#ffffff",

		active_tab = { bg_color = "#d9f9ff", fg_color = "#000000", intensity = "Bold" },
		inactive_tab = { bg_color = "#ffffff", fg_color = "#888888" },
		-- Auch der "Neue Tab" Button (+) sollte weiß sein
		new_tab = { bg_color = "#ffffff", fg_color = "#888888" },
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
	-- Füge dies in config.keys ein:
	{ key = "d", mods = "LEADER", action = act.ShowDebugOverlay },

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
		-- 'd' zum "Löschen" des aktuellen Workspaces (schließt alle Fenster/Tabs)
		{
			key = "d",
			action = wezterm.action_callback(function(window, pane)
				local current_workspace = window:active_workspace()
				local all_windows = wezterm.mux.all_windows()

				for _, win in ipairs(all_windows) do
					if win:get_workspace() == current_workspace then
						win:gui_window():perform_action(act.QuitApplication, pane)
					end
				end
			end),
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
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	-- allow `wezterm start -- something` to affect what we spawn
	-- in our initial window
	local args = {}
	if cmd then
		args = cmd.args
	end

	-- Set a workspace for coding on a current project
	-- Top pane is for the editor, bottom pane is for the build tool
	local project_dir = wezterm.home_dir .. "/wezterm"
	local tab, build_pane, window = mux.spawn_window({
		workspace = "coding",
		cwd = project_dir,
		args = args,
	})

	-- may as well kick off a build in that pane
	--	build_pane:send_text("echo hi")

	-- A workspace for interacting with a local machine that
	-- runs some docker containers for home automation
	local tab, pane, window = mux.spawn_window({
		workspace = "automation",
		args = { "ssh", "vault" },
	})
	local gui_window = window:gui_window()

	gui_window:maximize()
	gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)

	-- We want to startup in the coding workspace
	mux.set_active_workspace("coding")
end)

return config
