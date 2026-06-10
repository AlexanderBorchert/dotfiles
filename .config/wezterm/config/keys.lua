local wezterm = require("wezterm")
local action = wezterm.action
local M = {}

-- Hier lagern wir die Hilfetexte für das UI aus (saubere Trennung)
M.key_table_hints = {
	["leader"] = "   [w]Workspaces   [t]Tabs/Windows   ",
	["workspaces"] = " 🚀 WORKSPACES:   [w]switch   [c]create   [r]rename   [d]delete   ",
	["tabs"] = " 📑 Windows:   [w]switch   [c]create   [r]rename   [d]delete   ",
}

function M.apply(config)
	config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 10000 }

	config.keys = {

		{
			key = "T",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				package.loaded["config.helpers"] = nil
				local helpers = require("config.helpers")
				local data = helpers.get_active_tab_panes_with_processes(window)

				wezterm.log_info("data:" .. wezterm.to_string(data))
				wezterm.log_info("--- SCANNING FOR NVIM ---")

				-- 1. Loop through the list of panes returned by your helper
				for _, pane_info in ipairs(data or {}) do
					-- Adjust 'pane_info.process' based on how your helper structures the data
					local process_name = pane_info.process or ""

					-- 2. Check if the process name contains "nvim"
					if string.match(process_name:lower(), "nvim") then
						wezterm.log_info("Found Neovim in pane: " .. tostring(pane_info.pane_id))

						-- 3. Get the actual WezTerm pane object using its ID
						local target_pane = wezterm.mux.get_pane(pane_info.pane_id)

						if target_pane then
							-- 4. Send the command to Neovim.
							-- "\27" is the Escape key (to clear any partial commands),
							-- followed by the command and "\n" (Enter) to execute it.
							target_pane:send_text("\27:echo 'Hello from WezTerm!'\n")
						end
					end
				end
			end),
		},

		{
			key = "D",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				local tab = window:active_tab()
				-- Loops through and prints data for all panes belonging to the current tab
				for _, pane_info in ipairs(tab:panes_with_info()) do
					wezterm.log_info(
						string.format("Pane ID: %s | Active: %s ", pane_info.pane:pane_id(), pane_info.is_active)
					)
				end
				-- Automatically opens the Debug Overlay (CTRL+SHIFT+L) to show you the output
				window:perform_action(wezterm.action.ShowDebugOverlay, pane)
			end),
		},

		{ key = "F11", action = action.ToggleFullScreen },
		{ key = "[", mods = "LEADER", action = action.ActivateCopyMode },
		{ key = "q", mods = "LEADER", action = action.QuitApplication },
		{ key = "d", mods = "LEADER", action = action.ShowDebugOverlay },

		-- Splits & Tabs
		{ key = "v", mods = "LEADER", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "h", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "c", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },

		{ key = "h", mods = "CTRL|SHIFT", action = action.MoveTabRelative(-1) },
		{ key = "l", mods = "CTRL|SHIFT", action = action.MoveTabRelative(1) },

		{
			key = "h",
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				local tab = pane:tab()
				if tab:get_pane_direction("Left") ~= nil then
					window:perform_action(action.ActivatePaneDirection("Left"), pane)
				else
					window:perform_action(action.ActivateTabRelative(-1), pane)
				end
			end),
		},
		{
			key = "l",
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				local tab = pane:tab()
				if tab:get_pane_direction("Right") ~= nil then
					window:perform_action(action.ActivatePaneDirection("Right"), pane)
				else
					window:perform_action(action.ActivateTabRelative(1), pane)
				end
			end),
		},

		{ key = "w", mods = "LEADER", action = action.ActivateKeyTable({ name = "workspaces", one_shot = true }) },
		{ key = "t", mods = "LEADER", action = action.ActivateKeyTable({ name = "tabs", one_shot = true }) },
	}

	config.key_tables = {
		workspaces = {
			{
				key = "w",
				action = wezterm.action_callback(function(window, pane)
					local workspaces = {}
					for _, name in ipairs(wezterm.mux.get_workspace_names()) do
						table.insert(workspaces, { label = name, id = name })
					end
					window:perform_action(
						wezterm.action.InputSelector({
							title = "🚀 Workspace auswählen",
							choices = workspaces,
							fuzzy = true,
							action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
								if not id then
									return
								end
								inner_window:perform_action(action.SwitchToWorkspace({ name = id }), inner_pane)
							end),
						}),
						pane
					)
				end),
			},
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
			{
				key = "d",
				action = wezterm.action_callback(function(window, pane)
					local current_workspace = window:active_workspace()
					for _, win in ipairs(wezterm.mux.all_windows()) do
						if win:get_workspace() == current_workspace then
							win:gui_window():perform_action(action.QuitApplication, pane)
						end
					end
				end),
			},
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
			{ key = "d", action = action.CloseCurrentTab({ confirm = true }) },
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
end

return M
