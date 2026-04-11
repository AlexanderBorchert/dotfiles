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
config.show_tab_index_in_tab_bar = false

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
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 10000 }
config.keys = {
	{ key = "F11", action = act.ToggleFullScreen },
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "m", mods = "LEADER", action = act.TogglePaneZoomState },
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
		{ key = "c", action = act.SpawnTab("CurrentPaneDomain") },
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

		{
			key = "d",
			action = act.CloseCurrentTab({ confirm = true }),
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

wezterm.on("update-status", function(window, pane)
	local workspace = window:active_workspace()

	window:set_right_status(wezterm.format({
		-- Schlanker Balken links (Trennlinie)
		{ Foreground = { Color = "#e0e0e0" } },
		{ Text = "" },

		-- Das Icon in einem kräftigeren Blau
		{ Foreground = { Color = "#4285f4" } }, -- Google Blue
		{ Text = wezterm.nerdfonts.oct_project .. " " },

		-- Der Name im Design des aktiven Tabs
		{ Background = { Color = "#d9f9ff" } },
		{ Foreground = { Color = "#000000" } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = " " .. workspace .. " " },
	}))
end)

-- --------------------------------------------------------------------
-- 5. Startup Events
-- --------------------------------------------------------------------
local mux = wezterm.mux

local start_workspace = "learning vim"
local start_workspace_dir = wezterm.home_dir .. "/Projects/nvim/code/"
local start_tab_title = "vim"

local workspace_1 = "asm"
local workspace_1_dir = wezterm.home_dir .. "/Projects/asm/"
local tab_1_title = "duntemann"

local workspace_2 = "config"
local workspace_2_dir = wezterm.home_dir .. "/.dotfiles/"
local tab_2_title = "config"

wezterm.on("gui-startup", function()
	local start_tab, start_workspace_pane, start_workspace_window = mux.spawn_window({
		workspace = start_workspace,
		cwd = start_workspace_dir,
	})
	local gui_window = start_workspace_window:gui_window()
	mux.set_active_workspace(start_workspace)
	gui_window:maximize()
	start_tab:set_title(start_tab_title)

	local tab_1, _, _ = mux.spawn_window({
		workspace = workspace_1,
		cwd = workspace_1_dir,
	})
	tab_1:set_title(tab_1_title)

	local tab_2, _, _ = mux.spawn_window({
		workspace = workspace_2,
		cwd = workspace_2_dir,
	})
	tab_2:set_title(tab_2_title)
end)

-- 1. Intervall verkürzen, damit der Delay präzise geprüft wird (z.B. alle 200ms)
config.status_update_interval = 1000

wezterm.on("update-status", function(window, pane)
	local active_table = window:active_key_table()
	local leader_active = window:leader_is_active()
	local now = os.time() -- os.time() ist für einfache Sekunden-Checks stabiler

	-- Initialisierung des Timers in wezterm.GLOBAL
	if not wezterm.GLOBAL.leader_started_at then
		wezterm.GLOBAL.leader_started_at = 0
	end

	-- LOGIK: Wann wurde der Leader gestartet?
	if leader_active and wezterm.GLOBAL.last_leader_state == false then
		wezterm.GLOBAL.leader_started_at = now
	end
	wezterm.GLOBAL.last_leader_state = leader_active

	-- Wenn nichts aktiv ist: Status sofort leeren
	if not leader_active and not active_table then
		window:set_left_status("")
		return
	end

	-- DELAY CHECK:
	-- Wir zeigen den Leader-Status nur, wenn er seit mindestens 1 Sekunde aktiv ist
	-- (Hinweis: os.time() hat nur Sekunden-Präzision. Für ms-Präzision müsste man
	-- wezterm.time.now() nutzen, falls deine Version das unterstützt)
	if leader_active and (now - wezterm.GLOBAL.leader_started_at < 1) then
		window:set_left_status("")
		return
	end

	-- Anzeige-Logik (wird nur ausgeführt, wenn Delay vorbei oder Key-Table aktiv)
	local status_text = ""
	if leader_active then
		status_text = "   [w]Workspaces   [t]Tabs/Windows   "
	elseif active_table == "workspaces" then
		status_text = " 🚀 WORKSPACES:   [w]switch   [c]create   [r]rename   [d]delete   "
	elseif active_table == "tabs" then
		status_text = " 📑 Windows:   [w]switch   [c]create   [r]rename   [d]delete   "
	end

	local bg = "#eeeeee" -- Sehr helles, neutrales Grau
	local fg = "#555555" -- Dezentes Dunkelgrau
	if status_text ~= "" then
		window:set_left_status(wezterm.format({
			{ Background = { Color = bg } },
			{ Foreground = { Color = fg } },
			{ Text = status_text },
		}))
	end
end)

return config
