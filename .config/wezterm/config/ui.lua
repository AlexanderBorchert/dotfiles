local wezterm = require("wezterm")
local helpers = require("config.helpers") -- Importiert deinen Prozess-Scanner
local keys = require("config.keys") -- Importiert deine Tastatur-Hilfetexte

local M = {}

-- Deine Icon-Wörterbuchtabelle für die Tabs oben
local process_icons = {
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["fish"] = wezterm.nerdfonts.md_fish,
	["nvim"] = wezterm.nerdfonts.custom_neovim,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["node"] = wezterm.nerdfonts.mdi_nodejs,
	["python"] = wezterm.nerdfonts.dev_python,
	["git"] = wezterm.nerdfonts.dev_git,
	["ssh"] = wezterm.nerdfonts.fa_server,
	["wezterm"] = "𝕎",
	["asm"] = wezterm.nerdfonts.md_cpu_64_bit,
	["source"] = wezterm.nerdfonts.cod_code,
	["bug"] = wezterm.nerdfonts.cod_debug_alt,
	["other"] = wezterm.nerdfonts.cod_terminal,
}

function M.apply(config)
	-- Allgemeine UI Settings
	config.color_scheme = "Google Light (base16)"
	config.font = wezterm.font("JetBrainsMono Nerd Font")
	config.inactive_pane_hsb = { saturation = 0.98, brightness = 0.95 }
	config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	config.window_decorations = "RESIZE"
	config.status_update_interval = 3000

	-- Tab Bar Styling
	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = false
	config.show_new_tab_button_in_tab_bar = false
	config.show_tab_index_in_tab_bar = false
	config.tab_max_width = 32

	config.window_frame = {
		active_titlebar_bg = "#ffffff",
		inactive_titlebar_bg = "#ffffff",
	}

	config.colors = {
		tab_bar = {
			background = "#ffffff",
			inactive_tab_edge = "#ffffff",
			active_tab = { bg_color = "#d9f9ff", fg_color = "#000000", intensity = "Bold" },
			inactive_tab = { bg_color = "#ffffff", fg_color = "#888888" },
			new_tab = { bg_color = "#ffffff", fg_color = "#888888" },
		},
	}
end

-- 1. OBERER STATUS: Tab Titel & Icon Zuweisung
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.tab_title
	if not title or #title == 0 then
		title = "no name"
	end

	local icon = ""
	for name, sym in pairs(process_icons) do
		if title:lower():find(name) then
			icon = sym .. " "
			break
		end
	end

	return {
		{ Text = "  " .. icon .. title .. "  " },
	}
end)

-- 2. UNTERER STATUS: Kombiniertes Event für Links und Rechts
wezterm.on("update-status", function(window, pane)
	----------------------------------------
	-- LINKER STATUS (Leader & Keytables)
	----------------------------------------
	local active_table = window:active_key_table()
	local leader_active = window:leader_is_active()
	local now = os.time()

	if not wezterm.GLOBAL.leader_started_at then
		wezterm.GLOBAL.leader_started_at = 0
	end
	if leader_active and wezterm.GLOBAL.last_leader_state == false then
		wezterm.GLOBAL.leader_started_at = now
	end
	wezterm.GLOBAL.last_leader_state = leader_active

	if not leader_active and not active_table then
		window:set_left_status("")
	elseif leader_active and (now - wezterm.GLOBAL.leader_started_at < 1) then
		window:set_left_status("")
	else
		-- Zieht sich die Hilfetexte sauber und entkoppelt aus config/keys.lua
		local status_text = ""
		if leader_active then
			status_text = keys.key_table_hints["leader"]
		elseif active_table then
			status_text = keys.key_table_hints[active_table] or ""
		end

		if status_text ~= "" then
			window:set_left_status(wezterm.format({
				{ Background = { Color = "#eeeeee" } },
				{ Foreground = { Color = "#555555" } },
				{ Text = status_text },
			}))
		end
	end

	----------------------------------------
	-- RECHTER STATUS (Show Workspace)
	----------------------------------------
	local workspace = window:active_workspace()
	local right_elements = {}

	-- Dein blaues Workspace Design anhängen
	table.insert(right_elements, { Foreground = { Color = "#4285f4" } })
	table.insert(right_elements, { Text = wezterm.nerdfonts.oct_project .. " " })
	table.insert(right_elements, { Background = { Color = "#d9f9ff" } })
	table.insert(right_elements, { Foreground = { Color = "#000000" } })
	table.insert(right_elements, { Attribute = { Intensity = "Bold" } })
	table.insert(right_elements, { Text = " " .. workspace .. " " })

	window:set_right_status(wezterm.format(right_elements))
end)

return M
