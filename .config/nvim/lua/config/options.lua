vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"

-- indent new line with previous
vim.opt.breakindent = true
vim.opt.undofile = true
-- ignore case unless search starts with \C
vim.opt.ignorecase = true
-- :help smartcase ... e.g. even if ignorecase true,
-- if search is all caps, will search only all caps
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
-- time in millis after idle to update swapfile (default 4000)
vim.opt.updatetime = 250
-- time in millis for mapped sequence to complete
-- (or with which-key plugin to show popup with options)
vim.opt.timeoutlen = 500
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
