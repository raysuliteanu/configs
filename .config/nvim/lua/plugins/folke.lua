return {
	{ "folke/zen-mode.nvim" },
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	--	{ "folke/noice.nvim", enabled = false },
}
