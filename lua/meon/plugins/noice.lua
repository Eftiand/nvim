return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		cmdline = {
			enabled = true, -- Keep the enhanced command-line UI
		},
		popupmenu = {
			enabled = true, -- Keep the enhanced search UI
		},
		messages = {
			enabled = false, -- Disable general message notifications
		},
		lsp = {
			progress = {
				enabled = false, -- Disable LSP progress messages
			},
			hover = {
				enabled = true, -- Keep LSP hover features if needed
			},
			message = {
				enabled = false, -- Keep LSP signature help if needed
			},
			signature = {
				enabled = true, -- Keep LSP signature help if needed
			},
		},
		routes = {
			-- Suppress all types of LSP messages from csharp_ls
			{
				filter = {
					event = "lsp",
					cond = function(message)
						return message.client and message.client.name == "csharp_ls"
					end,
				},
				opts = { skip = true }, -- Skip all messages from csharp_ls
			},
			{
				filter = {
					event = "notify", -- Filter out notifications
					cond = function(message)
						return message.client and message.client.name == "csharp_ls"
					end,
				},
				opts = { skip = true }, -- Skip notifications from csharp_ls
			},
		},
	},
	dependencies = {
		"MunifTanjim/nui.nvim", -- Required dependency for Noice's UI enhancements
		"rcarriga/nvim-notify", -- nvim-notify for enhanced notifications
	},
}
