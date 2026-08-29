-- Place your general keymaps (vim.keymap.set) here

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
--
-- execute Makefile
vim.keymap.set('n', '<leader>m', ':w | make<CR>', { silent = true, desc = '[M]ake execution' })
vim.keymap.set('n', '<leader>r', ':w | make run<CR>', { silent = true, desc = '[M]ake run execution' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Exit insert mode by typing 'jj' quickly
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

---Wezterm
----------------------------------------------------------------------------------------------------------------------------
local function debug_wezterm()
  -- 1. Änderungen speichern und Projekt bauen
  vim.cmd 'write'
  local obj = vim.system({ 'make' }):wait()

  -- Optional: Falls make fehlschlägt, den Debugger gar nicht erst starten
  if obj.code ~= 0 then
    vim.notify('Kompilierung fehlgeschlagen!', vim.log.levels.ERROR)
    return
  end

  -- 2. ID des rechten WezTerm-Panes ermitteln
  local pane_id_raw = vim.fn.system 'wezterm cli get-pane-direction right'
  local pane_id = string.gsub(pane_id_raw, '%s+', '') -- Whitespaces entfernen

  -- Falls kein rechtes Pane existiert, erzeugen wir eines
  if pane_id == '' then
    -- Erstellt ein neues Pane rechts (nutzt standardmäßig 50% der Breite)
    local new_pane_raw = vim.fn.system 'wezterm cli split-pane --right'
    pane_id = string.gsub(new_pane_raw, '%s+', '')

    if pane_id == '' then return end

    -- Da das Pane brandneu ist, läuft dort garantiert noch kein GDB
    local cmd_raw = vim.fn.system 'make -s debug-cmd'
    local cmd = string.gsub(cmd_raw, '[\r\n]+$', '')

    if cmd ~= '' then
      local final_cmd = cmd .. ' -ex start'
      vim.fn.system(string.format("wezterm cli send-text --pane-id %s --no-paste '%s\r'", pane_id, final_cmd))
    end
    vim.fn.system 'wezterm cli activate-pane-direction right'
    return -- <-- FIX 1: Beendet die Funktion NUR, wenn das Pane neu erstellt wurde
  end

  -- 3. WezTerm-Panes als JSON abfragen (wenn das Pane bereits existierte)
  local json_raw = vim.fn.system 'wezterm cli list --format json'
  local ok, panes = pcall(vim.json.decode, json_raw)

  if not ok or not panes then return end

  -- 4. Vorhandenes Pane in der Liste suchen und Titel prüfen
  local gdb_running = false
  for _, pane in ipairs(panes) do
    if tostring(pane.pane_id) == pane_id then
      if string.find(string.lower(pane.title), 'gdb') then gdb_running = true end
      break
    end
  end

  -- 5. Befehl an das existierende Pane senden
  if gdb_running then
    -- Signal senden (Ctrl+C), um laufenden Prozess zu stoppen, falls GDB aktiv ist
    vim.fn.system(string.format("wezterm cli send-text --pane-id %s --no-paste '\x03'", pane_id))

    -- GDB läuft bereits -> Neustart mit 'start'
    vim.fn.system(string.format("wezterm cli send-text --pane-id %s --no-paste 'run\r'", pane_id))
  else
    -- GDB läuft nicht -> Debug-Befehl aus 'make' holen und starten
    local cmd_raw = vim.fn.system 'make -s debug-cmd'
    local cmd = string.gsub(cmd_raw, '[\r\n]+$', '')

    if cmd ~= '' then
      local final_cmd = cmd .. ' -ex start'
      vim.fn.system(string.format("wezterm cli send-text --pane-id %s --no-paste '%s\r'", pane_id, final_cmd))
    else
      print "Fehler: 'make -s debug-cmd' hat keinen Befehl zurückgegeben."
    end
  end

  -- Am Ende den Fokus auf das rechte WezTerm-Pane (Debug-Pane) setzen
  vim.fn.system 'wezterm cli activate-pane-direction right'
end -- <-- FIX 2: Hier schließt die Funktion jetzt korrekt ab

-- Keymap auf <leader>d legen
vim.keymap.set('n', '<leader>d', debug_wezterm, { desc = 'Start/Restart GDB in right WezTerm pane', silent = true })
