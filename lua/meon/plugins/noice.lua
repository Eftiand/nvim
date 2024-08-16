return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- Insert the noice setup configuration here
		routes = {
			{ filter = { event = "notify", find = "ping" }, opts = { skip = true } },
			{ filter = { event = "notify", find = "pong" }, opts = { skip = true } },
			{ filter = { find = "alternate" }, opts = { skip = true } },
		},
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
}
