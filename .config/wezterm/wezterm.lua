local wezterm = require("wezterm")
local action = wezterm.action
local config = wezterm.config_builder()
local mux = wezterm.mux
local homedir = wezterm.home_dir

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
config.tab_max_width = 32 -- Standard ist 16, hier auf 32 erhöht

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
	{ key = "F11", action = action.ToggleFullScreen },
	{ key = "[", mods = "LEADER", action = action.ActivateCopyMode },
	{
		key = "q",
		mods = "LEADER",
		action = wezterm.action.QuitApplication,
	},
	{ key = "d", mods = "LEADER", action = action.ShowDebugOverlay },

	-- Splits & Tabs
	{ key = "v", mods = "LEADER", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "c", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },
	{ key = "p", mods = "LEADER", action = action.ActivateTabRelative(-1) },
	{ key = "n", mods = "LEADER", action = action.ActivateTabRelative(1) },

	-- Resizing (Ctrl + Shift + hjkl)
	{ key = "h", mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "l", mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "j", mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Down", 5 }) },
	{ key = "k", mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Up", 5 }) },

	{
		key = "w",
		mods = "LEADER",
		action = action.ActivateKeyTable({
			name = "workspaces",
			one_shot = true, -- Automatically exit table after one action
		}),
	},
	{
		key = "t",
		mods = "LEADER",
		action = action.ActivateKeyTable({
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
			action = action.ShowLauncherArgs({
				flags = "WORKSPACES",
				title = "🚀 Workspace auswählen",
				help_text = "",
			}),
		},
		-- 'c' to create a new workspace
		{
			key = "c",
			action = action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(action.SwitchToWorkspace({ name = line }), pane)
					end
				end),
			}),
		},

		-- 'r' to rename current workspace
		{
			key = "r",
			action = action.PromptInputLine({
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
						win:gui_window():perform_action(action.QuitApplication, pane)
					end
				end
			end),
		},

		-- Escape to cancel
		{ key = "Escape", action = "PopKeyTable" },
	},
	tabs = {
		{ key = "c", action = action.SpawnTab("CurrentPaneDomain") },
		{
			key = "r",
			action = action.PromptInputLine({
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
			action = action.CloseCurrentTab({ confirm = true }),
		},
	},
}

-- Quick Tab Access (Leader + 1-9)
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = action.ActivateTab(i - 1),
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
	["wezterm"] = "𝕎",
	["asm"] = wezterm.nerdfonts.md_cpu_64_bit,
	["other"] = wezterm.nerdfonts.cod_terminal,
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- Nutze den Titel, den du via set_title vergeben hast
	local title = tab.tab_title
	if not title or #title == 0 then
		title = tab.active_pane.title
	end

	-- Icon nur suchen, wenn das Wort im Titel vorkommt
	local icon = ""
	for name, sym in pairs(process_icons) do
		if title:lower():find(name) then
			icon = sym .. " "
			break
		end
	end

	-- Das gewünschte Padding: 2 Leerzeichen links und rechts
	return {
		{ Text = "  " .. icon .. title .. "  " },
	}
end)

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

wezterm.on("gui-startup", function()
	-- Workspace learning vim
	local learning_vim_ws_name = "learning vim"
	local learning_vim_dir = homedir .. "/Projects/nvim/code/"
	local learning_vim_tab, learning_vim_pane, learning_vim_window = mux.spawn_window({
		workspace = learning_vim_ws_name,
		cwd = learning_vim_dir,
	})
	learning_vim_tab:set_title("vim")
	local other_tab = learning_vim_window:spawn_tab({ cwd = learning_vim_dir })
	other_tab:set_title("other")
	learning_vim_tab:activate()

	-- Workspace learning assembler
	local learning_asm_ws_name = "asm"
	local learning_asm_dir = homedir .. "/Projects/asm/"
	local learning_asm_tab, _, learning_asm_window = mux.spawn_window({
		workspace = learning_asm_ws_name,
		cwd = learning_asm_dir,
	})
	learning_asm_tab:set_title("duntemann asm")
	local git_other_tab = learning_asm_window:spawn_tab({ cwd = learning_asm_dir })
	git_other_tab:set_title("other")
	learning_asm_tab:activate()

	-- Workspace configs
	local dotfiles_dir = homedir .. "/.dotfiles"
	local wezterm_dir = dotfiles_dir .. "/.config/wezterm"
	local nvim_dir = dotfiles_dir .. "/.config/nvim"
	local wezterm_tab, _, configs_window = mux.spawn_window({
		workspace = "configs",
		cwd = wezterm_dir,
		-- args = { "nvim", ".config/wezterm/wezterm.lua" },
		args = { "fish", "-c", "nvim wezterm.lua; exec fish" },
	})
	wezterm_tab:set_title("wezterm")
	local nvim_tab = configs_window:spawn_tab({
		cwd = dotfiles_dir,
		args = { "fish", "-c", "cd " .. nvim_dir .. "; nvim init.lua; exec fish" },
	})
	nvim_tab:set_title("nvim")
	local git_stow_tab = configs_window:spawn_tab({ cwd = dotfiles_dir })
	git_stow_tab:set_title("git stow")
	git_stow_tab = configs_window:spawn_tab({ cwd = dotfiles_dir })
	git_stow_tab:set_title("other")
	wezterm_tab:activate()

	mux.set_active_workspace(learning_vim_ws_name)
end)

-- 1. Intervall verkürzen, damit der Delay präzise geprüft wird (z.B. alle 200ms)
config.status_update_interval = 3000

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
