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

vim.keymap.set("n", "gf", function()
	if require("obsidian").util.cursor_on_markdown_link() then
		return "<cmd>ObsidianFollowLink<CR>"
	else
		return "gf"
	end
end, { noremap = false, expr = true })

vim.keymap.set("n", "<leader>f.", function()
	require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
end)
--
-- IntelliJ Keymaps - WIP
vim.keymap.set("i", "<C-y>", "<Esc>yy", { desc = "Copy ([Y]ank) current line" })
vim.keymap.set("i", "<C-d>", "<Esc>yypo", { desc = "Duplicate current line" })
