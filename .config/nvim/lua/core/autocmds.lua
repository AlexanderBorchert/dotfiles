--- scheme
-----------------------------------------------------------------------------------

-- Automatically format Racket files on save using your installed raco tool
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.rkt',
  callback = function()
    -- Uses the built-in Racket formatter if available via LSP,
    -- or falls back to standard internal formatting
    vim.lsp.buf.format { async = false }
  end,
})



-- In lua/core/autocmds.lua einfügen:
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'racket', 'lisp' },
  callback = function()
    vim.opt_local.lisp = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})
