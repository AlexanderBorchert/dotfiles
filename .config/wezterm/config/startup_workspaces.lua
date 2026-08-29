local wezterm = require("wezterm")
local mux = wezterm.mux
local homedir = wezterm.home_dir
local M = {}

function M.setup()
	wezterm.on("gui-startup", function()
		-- Workspace learning vim
		------------------------------------------------------------------------------------------------
		-- learning vim tab
		local learning_vim_ws_name = "learning vim"
		local learning_vim_dir = homedir .. "/Projects/nvim/code/"
		local learning_vim_tab, _, learning_vim_window = mux.spawn_window({
			workspace = learning_vim_ws_name,
			cwd = learning_vim_dir,
		})
		learning_vim_tab:set_title("vim")
		-- other tab
		local other_tab = learning_vim_window:spawn_tab({ cwd = learning_vim_dir })
		other_tab:set_title("other")

		learning_vim_tab:activate()

		-- Workspace learning assembler
		------------------------------------------------------------------------------------------------
		-- learning asm tab
		local learning_asm_ws_name = "asm"
		local learning_asm_dir = homedir .. "/Projects/asm/"
		local learning_asm_tab, _, learning_asm_window = mux.spawn_window({
			workspace = learning_asm_ws_name,
			cwd = learning_asm_dir,
		})
		learning_asm_tab:set_title("duntemann asm")

		-- other tab
		local git_other_tab1 = learning_asm_window:spawn_tab({ cwd = learning_asm_dir })
		git_other_tab1:set_title("other")

		learning_asm_tab:activate()

		-- Workspace learning C
		------------------------------------------------------------------------------------------------
		--- learning asm tab
		local learning_c_ws_name = "C"
		local learning_c_dir = homedir .. "/Projects/C/KR_book"
		local learning_c_tab, _, learning_c_window = mux.spawn_window({
			workspace = learning_c_ws_name,
			cwd = learning_c_dir,
		})
		learning_c_tab:set_title("K&R")

		--- other tab
		local git_other_tab2 = learning_c_window:spawn_tab({ cwd = learning_c_dir })
		git_other_tab2:set_title("other")

		learning_c_tab:activate()

		-- Workspace learning scheme
		------------------------------------------------------------------------------------------------
		--- learning scheme tab
		local learning_scheme_ws_name = "scheme"
		local learning_scheme_dir = homedir .. "/Projects/scheme"
		local learning_scheme_tab, _, learning_scheme_window = mux.spawn_window({
			workspace = learning_scheme_ws_name,
			cwd = learning_scheme_dir,
		})
		learning_scheme_tab:set_title("scheme")

		--- other tab
		local git_other_tab2 = learning_scheme_window:spawn_tab({ cwd = learning_scheme_dir })
		git_other_tab2:set_title("other")

		learning_scheme_tab:activate()

		-- Workspace configs
		------------------------------------------------------------------------------------------------
		local dotfiles_dir = homedir .. "/.dotfiles"
		local wezterm_dir = dotfiles_dir .. "/.config/wezterm/config"
		local nvim_dir = dotfiles_dir .. "/.config/nvim"
		local fish_dir = dotfiles_dir .. "/.config/fish"

		-- wezterm tab
		local wezterm_tab, _, configs_window = mux.spawn_window({
			workspace = "configs",
			cwd = wezterm_dir,
			args = { "fish", "-c", "yazi; exec fish" },
		})
		wezterm_tab:set_title("wezterm")

		-- nvim tab
		local nvim_tab = configs_window:spawn_tab({
			cwd = dotfiles_dir,
			args = { "fish", "-c", "cd " .. nvim_dir .. "; nvim init.lua; exec fish" },
		})
		nvim_tab:set_title("nvim")

		-- fish tab
		local fish_tab = configs_window:spawn_tab({
			cwd = fish_dir,
			args = { "fish", "-c", "cd " .. fish_dir .. "; yazi; exec fish" },
		})
		fish_tab:set_title("fish")

		-- git stow tab
		local git_stow_tab = configs_window:spawn_tab({ cwd = dotfiles_dir })
		git_stow_tab:set_title("git stow")

		-- other tab
		configs_window:spawn_tab({ cwd = dotfiles_dir }):set_title("other")
		wezterm_tab:activate()

		-- Workspace other
		------------------------------------------------------------------------------------------------
		local other_ws_name = "other"
		local other_dir = homedir
		local other_tab, _, _ = mux.spawn_window({
			workspace = other_ws_name,
			cwd = other_dir,
		})
		other_tab:set_title("other")

		-- Workspace learning azure
		------------------------------------------------------------------------------------------------
		local learning_azure_ws_name = "learning azure"
		local learning_azure_dir = homedir .. "/Projects/learning_azure/"
		local learning_azure_tab, _, learning_azure_window = mux.spawn_window({
			workspace = learning_azure_ws_name,
			cwd = learning_azure_dir,
		})
		learning_azure_tab:set_title("azure cli")
		local git_other_tab3 = learning_azure_window:spawn_tab({ cwd = learning_azure_dir })
		git_other_tab3:set_title("other")
		learning_azure_tab:activate()
		------------------------------------------------------------------------------------------------

		-- Start-Workspace beim Booten erzwingen
		mux.set_active_workspace(learning_vim_ws_name)
	end)
end

return M
