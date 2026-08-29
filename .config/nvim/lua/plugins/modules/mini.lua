return { -- Collection of various small independent plugins/modules
  'nvim-mini/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }
    require('mini.pairs').setup()

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Simple and easy statusline.
    local statusline = require 'mini.statusline'
    local text_color = '#111111'
    vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = text_color, bold = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineFileinfo', { fg = text_color, bold = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { fg = text_color })

    statusline.setup {
      use_icons = vim.g.have_nerd_font,
      content = {
        -- Force the active window layout here
        active = function()
          local mode, mode_hl = statusline.section_mode { decapitalize = true }
          local git = statusline.section_git { trunc_width = 40 }
          local diff = statusline.section_diff { trunc_width = 45 }
          local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
          local lsp = statusline.section_lsp { trunc_width = 75 }
          local filename = statusline.section_filename { trunc_width = 140 }

          -- 1. Das passende Icon für den Dateityp (z.B. " ") abrufen
          local file_icon = ''
          if vim.g.have_nerd_font then
            local has_icons, mini_icons = pcall(require, 'mini.icons')
            if has_icons then file_icon = mini_icons.get('filetype', vim.bo.filetype) .. ' ' end
          end

          -- 2. Das Icon direkt in den String einbetten: " lua utf-8[unix]"
          local fileinfo = string.format('%s%s %s[%s]', file_icon, vim.bo.filetype, vim.bo.fileencoding, vim.bo.fileformat)

          return statusline.combine_groups {
            { hl = mode_hl, strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
          }
        end,
      },
    }
    -- ... and there is more!
    --  Check out: https://github.com/nvim-mini/mini.nvim

    -- ... and there is more!
    --  Check out: https://github.com/nvim-mini/mini.nvim
  end,
}
