return {
  "alexghergh/nvim-tmux-navigation",
  -- This line ensures the plugin is loaded when you start Neovim
  event = "VeryLazy",
  -- You can add a config function to set up options
  config = function()
    require("nvim-tmux-navigation").setup {
      disable_when_zoomed = true, -- Optional: Keep navigation within Neovim when zoomed
    }
  end,
  -- Here you can set the keymaps. LazyVim will automatically handle the mapping.
  keys = {
    { "<C-h>", function() require("nvim-tmux-navigation").NvimTmuxNavigateLeft() end, desc = "Tmux navigate left" },
    { "<C-j>", function() require("nvim-tmux-navigation").NvimTmuxNavigateDown() end, desc = "Tmux navigate down" },
    { "<C-k>", function() require("nvim-tmux-navigation").NvimTmuxNavigateUp() end, desc = "Tmux navigate up" },
    { "<C-l>", function() require("nvim-tmux-navigation").NvimTmuxNavigateRight() end, desc = "Tmux navigate right" },
    { "<C-\\>", function() require("nvim-tmux-navigation").NvimTmuxNavigateLastActive() end, desc = "Tmux navigate last active" },
  },
}
