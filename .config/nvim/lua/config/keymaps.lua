-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "\\", "<cmd>Neotree focus toggle<cr>", { desc = "Toggle Neotree file viewer" })
vim.keymap.set("n", "\\b", "<cmd>Neotree focus buffers toggle<cr>", { desc = "Toggle Neotree buffer viewer" })
vim.keymap.set(
	"n",
	"\\g",
	"<cmd>Neotree focus git_status toggle float<cr>",
	{ desc = "Toggle Neotree git status viewer" }
)

-- from Primeagen https://raw.githubusercontent.com/ThePrimeagen/init.lua/master/lua/theprimeagen/remap.lua
-- move selected text up and down like IntelliJ <c-shift-up/down>
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- join line with next but keep cursor at current location
vim.keymap.set("n", "J", "mzJ`z")

-- when inc scroll, keep cursor centered on the page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set("n", "Q", "<nop>")

-- end Primeagen

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Obsidian plugin
-- change cwd to Obsidian vault
vim.keymap.set("n", "<leader>Oo", ":cd /home/ray/Documents/Obsidian/Ray<cr>")

-- convert note to template and remove leading white space
vim.keymap.set("n", "<leader>On", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>Of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")

-- search for files in full vault
vim.keymap.set("n", "<leader>Os", ':Telescope find_files search_dirs={"/home/ray/Documents/Obsidian/Ray"}<cr>')
vim.keymap.set("n", "<leader>Oz", ':Telescope live_grep search_dirs={"/home/ray/Documents/Obsidian/Ray"}<cr>')

-- search for files in notes only
vim.keymap.set(
	"n",
	"<leader>Ois",
	':Telescope find_files search_dirs={"/home/ray/Documents/Obsidian/Ray/Resources/Notes"}<cr>'
)
vim.keymap.set("n", "<leader>Oiz", ':Telescope live_grep search_dirs={"/home/ray/Documents/Obsidian/Ray"}<cr>')

-- for review workflow
-- move file in current buffer to zettelkasten folder
vim.keymap.set("n", "<leader>Ok", ":!mv '%:p' /home/ray/Documents/Obsidian/Ray/Resources/Notes<cr>:bd<cr>")
-- delete file in current buffer
vim.keymap.set("n", "<leader>Odd", ":!rm '%:p'<cr>:bd<cr>")
-- end Obsidian plugin

-- IntelliJ Keymaps - WIP
vim.keymap.set("i", "<C-y>", "<Esc>yy", { desc = "Copy ([Y]ank) current line" })
vim.keymap.set("i", "<C-d>", "<Esc>yypo", { desc = "Duplicate current line" })
