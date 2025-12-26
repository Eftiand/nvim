return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			-- enable indentation
			indent = { enable = true },
			-- enable autotagging (w/ nvim-ts-autotag plugin)
			autotag = {
				enable = true,
				enable_rename = true,
				enable_close = true,
				enable_close_on_slash = true,
				filetypes = {
					"html",
					"xml",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"lua",
				"xml",
				"html",
				"css",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"c_sharp",
				"python",
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"markdown",
				"markdown_inline", -- needed for proper markdown support
				"go",
				"gomod",
				"gosum",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
