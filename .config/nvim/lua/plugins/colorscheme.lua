-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "light",
    },
    config = function(_, opts)
      require("onedark").setup(opts)
      require("onedark").load()
    end,
  },
}
