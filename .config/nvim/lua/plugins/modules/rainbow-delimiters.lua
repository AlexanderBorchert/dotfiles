return {
  'HiPhish/rainbow-delimiters.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = 'BufReadPost',
  config = function()
    local rainbow_delimiters = require 'rainbow-delimiters'

    require('rainbow-delimiters.setup').setup {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
      },
      -- Die 'query'-Sektion lassen wir komplett leer.
      -- Dadurch greift für JEDE Sprache das Standard-Verhalten des Plugins!
    }
  end,
}
