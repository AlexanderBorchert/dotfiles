local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 1. System- & Shell-Einstellungen
config.default_prog = { "fish", "-l" }

if os.getenv("WSL_DISTRO_NAME") then
	config.default_domain = "WSL:" .. os.getenv("WSL_DISTRO_NAME")
end

-- 2. Modulare Konfiguration laden & anwenden
require("config.ui").apply(config)
require("config.keys").apply(config)
require("config.startup_workspaces").setup()

return config
