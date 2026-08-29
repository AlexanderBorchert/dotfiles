return { -- Theme auf Google Light (Base16) umstellen
  'tinted-theming/base16-vim',
  priority = 1000, -- Wichtig, damit das Theme als Erstes geladen wird
  config = function() vim.cmd.colorscheme 'base16-google-light' end,
}
