return {
	-- Adds git related signs to the gutter, as well as utilities for managing changes
	-- See `:help gitsigns` to understand what the configuration keys do
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_", show_count = true },
				topdelete = { text = "‾", show_count = true },
				changedelete = { text = "~" },
			},
		},
	},
}