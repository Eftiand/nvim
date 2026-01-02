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
		{
			"<leader>sj",
			function()
				-- Get the content under cursor or current line
				local content = vim.fn.expand("<cWORD>")
				if content == "" then
					content = vim.api.nvim_get_current_line()
				end

				-- Try to find JSON object/array in the content
				local json_start = content:find("[{%[]")
				if json_start then
					content = content:sub(json_start)
				end

				-- Open in vertical split
				vim.cmd("vnew")
				vim.bo.buftype = "nofile"
				vim.bo.bufhidden = "wipe"
				vim.bo.filetype = "json"

				-- Insert content
				vim.api.nvim_buf_set_lines(0, 0, -1, false, { content })

				-- Try to format with jq if available
				if vim.fn.executable("jq") == 1 then
					vim.cmd("silent! %!jq .")
				end
			end,
			desc = "Open JSON in buffer",
			ft = "dbout",
		},
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
