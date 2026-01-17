return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = {
        lualine_a = {},
        lualine_b = opts.sections.lualine_b,
        lualine_c = opts.sections.lualine_c,
        lualine_x = opts.sections.lualine_x,
        lualine_y = {},
        lualine_z = {},
      }
    end,
  },
}
