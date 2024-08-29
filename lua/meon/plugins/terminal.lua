return {
	{
		"voldikss/vim-floaterm",
		config = function()
			-- Set terminal size and position
			vim.g.floaterm_position = "center" -- Center the terminal
			vim.g.floaterm_width = 0.7 -- Set width to 70% of screen
			vim.g.floaterm_height = 0.6 -- Set height to 60% of screen

			vim.api.nvim_create_user_command("T", "FloatermToggle", {})

			-- Set key mappings for floaterm
			vim.cmd([[
              augroup FloatermMappings
              autocmd!
              autocmd! TermOpen term://*toggleterm#* tnoremap <buffer> <ESC> <C-\><C-n>
              augroup END
              ]])
		end,
	},
}
