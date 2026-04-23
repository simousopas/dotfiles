-- vim:nowrap
-- Helpful resources:
-- https://neovim.io/doc/user/lua-guide.html
-- https://neovim.io/doc/user/lua.html

-- Top-level options
-- =================
vim.opt.expandtab = false  -- Don't replace tabs with spaces.
vim.opt.shiftwidth = 0     -- # of spaces for each indent level. Set to 0 to use tabstop's value.
vim.opt.smartindent = true -- Auto indent when curly braces or keywords are present.
vim.opt.smarttab = false   -- <BS> will always delete one space at a time.
vim.opt.tabstop = 4        -- A tab is represented by this many spaces.

vim.opt.colorcolumn = ""                        -- Disable colored column.
vim.opt.completeopt = { "menuone", "noselect" } -- Let the completion menu have a single item and don't autos-select it.
vim.opt.cmdheight = 0                           -- Hide command line when not in use.
vim.opt.cursorline = true                       -- Emphasize the cursor's current line.
vim.opt.fileencoding = "utf-8"                  -- Default file encoding.
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.opt.foldcolumn = '1'
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.hlsearch = true                         -- Search highlighting enabled by default.
vim.opt.iskeyword:append("-")                   -- Consider these chars part of a word.
vim.opt.ignorecase = true                       -- Case-insensitive search.
vim.opt.laststatus = 3                          -- Show a single status line.
vim.opt.list = true                             -- Print invisible chars.
vim.opt.listchars = "tab:  ,trail:·"            -- How invisible chars should be represented.
vim.opt.mouse = "a"                             -- Mouse support available under all modes.
vim.opt.number = true                           -- Show line numbers.
vim.opt.relativenumber = true                   -- Show distance to other lines.
vim.opt.ruler = true                            -- Show current buffer position at the bottom right.
-- vim.opt.rulerformat = "%l,%c%V %p%%"         -- Position format. Disabled in favor of lualine.
vim.opt.scrolloff = 8                           -- Minimum number of lines to keep visible above/bellow the cursor.
vim.opt.sidescroll = 1                          -- Number of columns to scroll at a time.
vim.opt.sidescrolloff = 8                       -- Minimum number of columns to keep visible.
vim.opt.signcolumn = "yes"                      -- Always show the sign column to avoid shifting text when it show up.
vim.opt.shortmess:append("cI")                  -- Disable messages from completion results.
vim.opt.showbreak = "↳ "                        -- Representation of line break due to wrap.
vim.opt.smartcase = true                        -- Turn on case-sensitive search when capital letters are used.
vim.opt.spell = false                           -- Spellchecker disabled by default.
vim.opt.splitbelow = true                       -- Horizontal split goes bellow the current window.
vim.opt.splitright = true                       -- Vertical split goes to the right of the current window.
vim.opt.swapfile = false                        -- Disable swap file creation.
vim.opt.undofile = true                         -- Persist undo history.
vim.opt.whichwrap:append("h,l")                 -- Let these keys move cursor to the prev/next line.
vim.opt.wrap = false                            -- Wrap text.

if os.getenv("SKIP_LOADING_PLUGINS") == "yes" then
	if os.getenv("COLORTERM") ~= "truecolor" then
		vim.cmd.set("notermguicolors")
	end
	vim.cmd[[colorscheme default]]
	vim.api.nvim_set_hl(0, "Normal", { ctermbg=nil, bg=nil, force=true })
end


-- Keymaps
-- =======
local defaultOpts = {
	noremap = true, -- Don't remap recursively.
	silent = false,  -- Don't echo the map when it is triggered.
}

-- Clear any mappings for <Space> and set it as <Leader>.
vim.api.nvim_set_keymap("", "<SPACE>", "<NOP>", defaultOpts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- Vim-only mappings: Toggles
if os.getenv("ACT_AS_PAGER") == "yes" then
	vim.api.nvim_set_keymap("n", "q", ":q!<CR>", defaultOpts)
end

-- Toggle search matches highlighting when pressing <ESC> in normal mode.
vim.keymap.set("n", "<ESC>",
function ()
	if vim.o.hlsearch then
		vim.o.hlsearch = false

		local key = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
		vim.api.nvim_feedkeys(key, "n", true)

		print("Search highlight disabled.")
	else
		vim.o.hlsearch = true
	end
end, defaultOpts)

-- Toggle columns display
vim.keymap.set("n", "<leader>tc",
function ()
	if (vim.o.colorcolumn == "") then
		vim.opt.colorcolumn = "80,120,160"
	else vim.opt.colorcolumn = ""
	end
end, defaultOpts)

-- Toggle special chars display
local listchars_default = vim.o.listchars
vim.keymap.set("n", "<leader>tl",
function ()
	if (vim.o.listchars == listchars_default) then
		vim.opt.listchars = "eol:¬,tab:› ,lead:·,trail:·"
	else vim.opt.listchars = listchars_default
	end
end, defaultOpts)

vim.keymap.set("n", "<leader>ts", function ()
	if vim.o.spell then
		vim.o.spell = false
		print("Spellchecker disabled.")
	else
		vim.o.spell = true
		print("Spellchecker enabled.")
	end
end, defaultOpts)

vim.keymap.set("n", "<leader>tw", function ()
	if vim.o.wrap then
		vim.o.wrap = false
		print("Line wrap disabled.")
	else
		vim.o.wrap = true
		print("Line wrap enabled.")
	end
end, defaultOpts)

-- Vim-only mappings: Edition
vim.api.nvim_set_keymap("v", "<", "<gv", defaultOpts) -- Preserve visual mode after indenting text.
vim.api.nvim_set_keymap("v", ">", ">gv", defaultOpts)
vim.api.nvim_set_keymap("x", "<", "<gv", defaultOpts)
vim.api.nvim_set_keymap("x", ">", ">gv", defaultOpts)
vim.api.nvim_set_keymap("v", "<S-j>", ":move .+2<CR>==gv=gv", defaultOpts) -- Move selected text down/up.
vim.api.nvim_set_keymap("v", "<S-k>", ":move .-2<CR>==gv=gv", defaultOpts)
vim.api.nvim_set_keymap("x", "<S-j>", ":move '>+1<CR>gv-gv=gv", defaultOpts)
vim.api.nvim_set_keymap("x", "<S-k>", ":move '<-2<CR>gv-gv=gv", defaultOpts)
vim.api.nvim_set_keymap("x", "P", "I<C-r>0<ESC>", defaultOpts) -- Paste before visual block.
vim.api.nvim_set_keymap("n", "<S-k>", "k<S-j>", defaultOpts)   -- Append to line above.
vim.api.nvim_set_keymap("n", "<S-u>", "<C-r>", defaultOpts)    -- Redo w/ <S-u> instead of <C-r>
vim.api.nvim_set_keymap("n", "<leader>rr", ":%s///gc<left><left><left><left>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>rw", ":%s/\\<<C-r><C-w>\\>//gc<left><left><left>", { noremap = true })

-- Vim-only mappings: Navigation
vim.api.nvim_set_keymap("i", "<C-c>", "<ESC>:quit!<CR>", defaultOpts)
vim.api.nvim_set_keymap("i", "<C-x>", "<ESC>:quitall!<CR>", defaultOpts)
vim.api.nvim_set_keymap("n", "j", "v:count ? 'j' : 'gj'", { noremap = true, expr = true }) -- Treat line wraps as a distinct line.
vim.api.nvim_set_keymap("n", "k", "v:count ? 'k' : 'gk'",  { noremap = true, expr = true })
vim.api.nvim_set_keymap("n", "<leader>h", "<C-w>h", defaultOpts) -- Focus window left/bellow/above/right
vim.api.nvim_set_keymap("n", "<leader>j", "<C-w>j", defaultOpts)
vim.api.nvim_set_keymap("n", "<leader>k", "<C-w>k", defaultOpts)
vim.api.nvim_set_keymap("n", "<leader>l", "<C-w>l", defaultOpts)
vim.api.nvim_set_keymap("n", "tt", ":tabnew<CR>", defaultOpts)   -- Open new tab / current file on new tab.
vim.api.nvim_set_keymap("n", "te", ":tabnew %<CR>", defaultOpts)
vim.api.nvim_set_keymap("n", "th", ":tabfirst<CR>", defaultOpts) -- Go to first/previous/next/last/tab.
vim.api.nvim_set_keymap("n", "tj", ":tabprevious<CR>", defaultOpts)
vim.api.nvim_set_keymap("n", "tk", ":tabnext<CR>", defaultOpts)
vim.api.nvim_set_keymap("n", "tl", ":tablast<CR>", defaultOpts)
vim.api.nvim_set_keymap("n", "ts", ":tab split<CR>", defaultOpts)
for i = 1,9 do -- Go to n-th tab.
	local ith = tostring(i)
	local src = "t" .. ith
	local dst = ith .. "gt"
	vim.api.nvim_set_keymap("n", src, dst, defaultOpts)
end
	-- Improve default search behavior by highlighting w/o moving to the next match.
vim.keymap.set("n", "*", function ()
	vim.opt.hlsearch = true
	vim.cmd([[keepjumps normal! msHmt`s*`tzt`s]])
end, defaultOpts)
vim.keymap.set("n", "#", function ()
	vim.opt.hlsearch = true
	vim.cmd([[keepjumps normal! msHmt`s#`tzt`s]])
end, defaultOpts)

-- Re-enable search matches highlighting when searching for the next match.
vim.keymap.set("n", "n", function ()
	vim.opt.hlsearch = true
	local key = vim.api.nvim_replace_termcodes("n", true, false, true)
	vim.api.nvim_feedkeys(key, "n", true)
end, defaultOpts)
vim.keymap.set("n", "N", function ()
	vim.opt.hlsearch = true
	local key = vim.api.nvim_replace_termcodes("N", true, false, true)
	vim.api.nvim_feedkeys(key, "n", true)
end, defaultOpts)


-- Autocmds
-- ========
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function ()
		vim.cmd.set("spell")
	end
})


-- Plugins (TODO)
-- =======
vim.cmd.colorscheme("default")
vim.api.nvim_set_hl(0, "Normal", { ctermbg=nil, bg=nil, force=true })
