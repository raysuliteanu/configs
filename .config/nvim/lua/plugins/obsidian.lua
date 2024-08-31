return {
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("obsidian").setup({
				workspaces = {
					{
						name = "Ray",
						path = "/home/ray/Documents/Obsidian/Ray",
					},
				},
				notes_subdir = "Inbox",
				new_notes_location = "notes_subdir",
				disable_frontmatter = true,
				templates = {
					subdir = "Templates",
					date_format = "%Y-%m-%d",
					time_format = "%H:%M:%S",
				},
				-- key mappings, below are the defaults
				mappings = {
					-- overrides the 'gf' mapping to work on markdown/wiki links within your vault
					["gf"] = {
						action = function()
							return require("obsidian").util.gf_passthrough()
						end,
						opts = { noremap = false, expr = true, buffer = true },
					},
				},
				completion = {
					nvim_cmp = true,
					min_chars = 2,
				},
				ui = {
					enable = true,
					opts = {
						conceallevel = 1,
					},
					-- Disable some things below here because I set these manually for all Markdown files using treesitter
					-- checkboxes = {},
					-- bullets = {},
				},
			})

			-- >>> oo # from shell, navigate to vault (optional)
			--
			-- # NEW NOTE
			-- >>> on "Note Name" # call my "obsidian new note" shell script (~/bin/on)
			-- >>>
			-- >>> ))) <leader>on # inside vim now, format note as template
			-- >>> ))) # add tag, e.g. fact / blog / video / etc..
			-- >>> ))) # add hubs, e.g. [[python]], [[machine-learning]], etc...
			-- >>> ))) <leader>of # format title
			--
			-- # END OF DAY/WEEK REVIEW
			-- >>> or # review notes in inbox
			-- >>>
			-- >>> ))) <leader>ok # inside vim now, move to zettelkasten
			-- >>> ))) <leader>odd # or delete
			-- >>>
			-- >>> og # organize saved notes frm zettelkasten into notes/[tag] folders
			-- >>> ou # sync local with Notion
			--
		end,
	},
}
