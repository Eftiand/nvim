return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	keys = {
		{ "<leader>sq", "<Cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
		{ "<leader>sf", "<Cmd>DBUIFindBuffer<CR>", desc = "Find DB buffer" },
		{ "<leader>sa", "<Cmd>DBUIAddConnection<CR>", desc = "Add DB connection" },
		{ "<leader>sl", "<Cmd>DBUILastQueryInfo<CR>", desc = "Last query info" },
	},
	init = function()
		-- Use nerd fonts icons
		vim.g.db_ui_use_nerd_fonts = 1

		-- Save queries location
		vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

		-- Disable execute on save
		vim.g.db_ui_execute_on_save = 0

		-- Connections are added dynamically via DBUIAddConnection
		-- They persist in vim.g.db_ui_save_location
		vim.g.dbs = {}
	end,
	config = function()
		-- Setup completion for sql files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function()
				require("cmp").setup.buffer({
					sources = {
						{ name = "vim-dadbod-completion" },
						{ name = "buffer" },
					},
				})
			end,
		})
	end,
}
