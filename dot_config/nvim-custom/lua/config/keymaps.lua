-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- q in normal mode starts a macro. I often misfire this when typing :q. It is difficult to
-- exit macro mode so I am rebinding it to gq.
-- vim.keymap.set('n', 'q', '<Nop>', { noremap = true, silent = true })
-- vim.keymap.set('n', 'gq', 'q', { desc = 'Start/Stop Macro', noremap = true, silent = true })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-w>m', '<C-w>h', { noremap = true, silent = true, desc = 'Move Left' })
vim.keymap.set('n', '<C-w>n', '<C-w>j', { noremap = true, silent = true, desc = 'Move Down' })
vim.keymap.set('n', '<C-w>e', '<C-w>k', { noremap = true, silent = true, desc = 'Move Up' })
vim.keymap.set('n', '<C-w>i', '<C-w>l', { noremap = true, silent = true, desc = 'Move Right' })

local nmap = function(keys, cmd, desc)
  vim.keymap.set('n', '<leader>' .. keys, cmd, { desc = desc, noremap = true, silent = true })
end

nmap('bb', '<cmd>e #<cr>', '[b]ack to Previous [b]uffer')
nmap('bd', '<cmd>bd<cr>', '[b]uffer [d]elete')
nmap('bD', '<cmd>bd!<cr>', 'Force [b]uffer [D]elete')
nmap('by', 'gg"+yG', '[b]uffer [y]ank')
-- Select buffer and switch to select mode. From there you can type and the selected
-- text will be replaced.
nmap('br', 'ggVG<C-g>', '[b]uffer [r]eplace')
nmap('bs', 'ggVG', '[b]uffer [s]elect')
nmap('bf', ':let @+ = expand("%?")<cr>', '[B]uffer Yank [F]ilepath')

nmap('qq', '<cmd>q<cr>', '[Q]uit')
nmap('Q', '<cmd>q!<cr>', '[Q]uit no save')
nmap('wq', '<cmd>wq<cr>', 'Write Quit')
nmap('ww', '<cmd>w<cr>', '[W]rite')

nmap('gu', '<cmd>GitBlameCopyCommitURL<cr>', 'Copy Commit URL')
nmap('gU', '<cmd>GitBlameCopyFileURL<cr>', 'Copy File URL')
nmap('go', '<cmd>GitBlameOpenCommitURL<cr>', 'Open Commit URL')
nmap('gO', '<cmd>GitBlameOpenFileURL<cr>', 'Open File URL')

nmap('cd', vim.diagnostic.setloclist, '[C]ode [D]iagnostic Quickfix')
-----------------------------------------------------------------------------
-- Start Autoformat
-- These two use commands can be used to enable or disable auto formatting.
-- The variables set are used by conform.nvim. See init.lua.
local fidget = require 'fidget'
vim.api.nvim_create_user_command('FormatToggle', function(args)
  if vim.g.disable_autoformat == nil then
    vim.g.disable_autoformat = false
  end

  if vim.b.disable_autoformat == nil then
    vim.b.disable_autoformat = false
  end

  if args.bang then
    if vim.g.disable_autoformat == true then
      vim.g.disable_autoformat = false
    else
      vim.g.disable_autoformat = true
    end
    local g_fmt = vim.g.disable_autoformat == true and ' ' or 'X'
    fidget.notify('Global Autoformat [' .. g_fmt .. ']')
  else
    if vim.b.disable_autoformat == true or vim.g.disable_autoformat == nil then
      vim.b.disable_autoformat = false
    else
      vim.b.disable_autoformat = true
    end
    local b_fmt = vim.b.disable_autoformat == true and ' ' or 'X'
    fidget.notify('Buffer Autoformat [' .. b_fmt .. ']')
  end
end, { bang = true, desc = 'Toggle autoformatting. ! for global.' })

nmap('tf', '<cmd>FormatToggle<cr>', '[t]oggle buffer auto-[f]ormat')
nmap('tF', '<cmd>FormatToggle!<cr>', '[t]oggle global auto-[F]ormat')
-- End Autoformat
-----------------------------------------------------------------------------

vim.api.nvim_create_user_command('HelpCurwin', function(opts)
  HelpCurwin(opts.args)
end, { nargs = '?', complete = 'help', bar = true })

local did_open_help = false

function HelpCurwin(subject)
  local mods = 'silent noautocmd keepalt'
  local helpfile = vim.o.helpfile

  -- Open help buffer in the current window the first time
  if not did_open_help then
    vim.cmd(mods .. ' help')
    vim.cmd(mods .. ' wincmd p') -- Return to the previous window
    vim.cmd(mods .. ' helpclose') -- Close help buffer created by default behavior
    did_open_help = true
  end

  -- If a valid help subject is provided, navigate to it in the current window
  if subject and subject ~= '' and vim.fn.empty(vim.fn.getcompletion(subject, 'help')) == 0 then
    vim.cmd(mods .. ' edit ' .. helpfile)
    vim.cmd(mods .. ' help ' .. subject)
    vim.cmd 'setlocal buftype=help'
  elseif subject and subject ~= '' then
    print('No help topic found for: ' .. subject)
  else
    -- Open default help page in current window if no subject is given
    vim.cmd(mods .. ' edit ' .. helpfile)
    vim.cmd 'setlocal buftype=help'
  end
end
