-- to have the same white background in nvim as in wezterm
return {
  'tinted-theming/base16-vim',
  lazy = false, -- Muss sofort geladen werden, da es das UI beeinflusst
  priority = 1000, -- Höchste Priorität beim Laden
  config = function()
    vim.opt.termguicolors = true
    vim.cmd.colorscheme 'base16-google-light'
  end,
}
