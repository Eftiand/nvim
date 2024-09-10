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
		"rcarriga/nvim-notify", -- nvim-notify for enhanced notifications
	},
}
