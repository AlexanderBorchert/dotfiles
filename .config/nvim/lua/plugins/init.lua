-- 1. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- 2. Strictly load modules
require('lazy').setup({
  spec = {
    { import = 'plugins.modules' },
  },
})

