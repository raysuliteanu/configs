return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		config = function()
			require("render-markdown").setup({
				latex = { enabled = false },
			})
		end,
		opts = {},
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		ft = { "markdown" },
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },

		-- https://github.com/AstroNvim/astrocommunity/pull/1187/files#diff-c1a3cbf380896b973f6c61f41c5d615f87d388af172a12c597d9453051d9f4e7
		build = function(plugin)
			local package_manager = vim.fn.executable("yarn") and "yarn"
				or vim.fn.executable("npx") and "npx -y yarn"
				or false

			--- HACK: Use `yarn` or `npx` when possible, otherwise throw an error
			---@see https://github.com/iamcco/markdown-preview.nvim/issues/690
			---@see https://github.com/iamcco/markdown-preview.nvim/issues/695
			if not package_manager then
				error("Missing `yarn` or `npx` in the PATH")
			end

			local cmd = string.format(
				"!cd %s && cd app && COREPACK_ENABLE_AUTO_PIN=0 %s install --frozen-lockfile",
				plugin.dir,
				package_manager
			)

			vim.cmd(cmd)
		end,
	},
}
