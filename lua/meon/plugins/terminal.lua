return {
	{
		"voldikss/vim-floaterm",
		config = function()
			-- Set terminal size and position
			vim.g.floaterm_position = "center" -- Center the terminal
			vim.g.floaterm_width = 0.7 -- Set width to 90% of screen
			vim.g.floaterm_height = 0.6 -- Set height to 80% of screen

			vim.api.nvim_create_user_command("T", "FloatermToggle", {})
			vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
		end,
	},
}
