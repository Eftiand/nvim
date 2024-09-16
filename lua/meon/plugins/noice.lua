return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		messages = {
			enabled = false, -- Disable general message notifications
		},
		lsp = {
			progress = {
				enabled = false, -- Disable LSP progress messages
			},
			message = {
				enabled = false, -- Keep LSP signature help if needed
			},
		},
		routes = {},
	},
	dependencies = {
		"MunifTanjim/nui.nvim", -- Required dependency for Noice's UI enhancements
		{
			"rcarriga/nvim-notify",
			config = function()
				require("notify").setup({
					background_colour = "#1E1E2E", -- Set a valid background color (adjust this as needed)
				})
			end,
		},
	},
}
