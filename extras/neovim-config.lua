-- Inspired by https://codeberg.org/ihaveahax/nix-config
local keyset = vim.keymap.set

-- https://github.com/neoclide/coc.nvim

vim.cmd.colorscheme("vim")
vim.opt.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 6
-- show line and column number
vim.opt.ruler = true
-- show last used command at bottom
vim.opt.showcmd = true
-- allow mouse in all modes
vim.opt.mouse = "a"
-- i think this enables the use of backspace in some more contexts?
vim.opt.backspace = {'indent', 'eol', 'start'}
-- stop markdown files from folding
vim.opt.foldenable = false

-- allow Ctrl-K to add a newline but without entering insert mode
keyset("n", "<C-K>", "o<Esc>")

-- i often accidentally type the first letter as capital
vim.api.nvim_create_user_command("W", ":w", {})
vim.api.nvim_create_user_command("Wq", ":wq", {})
vim.api.nvim_create_user_command("Q", ":q", {})

-- vim-markdown
vim.g.vim_markdown_folding_disabled = true
vim.g.auto_save = true

-- don't need the "How-to disable mouse"
vim.cmd.aunmenu("PopUp.How-to\\ disable\\ mouse")
vim.cmd.aunmenu("PopUp.-1-")

-- COC

-- Autocomplete
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

