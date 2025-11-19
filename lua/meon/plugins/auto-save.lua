return {
	"okuuva/auto-save.nvim",
	event = { "InsertLeave", "TextChanged" },
	opts = {
		enabled = true,
		trigger_events = {
			immediate_save = { "BufLeave", "FocusLost" },
			defer_save = { "InsertLeave", "TextChanged" },
			cancel_deferred_save = { "InsertEnter" },
		},
		condition = function(buf)
			if vim.bo[buf].filetype == "harpoon" then
				return false
			end
			return vim.bo[buf].modifiable
		end,
		write_all_buffers = false,
		debounce_delay = 135,
		debug = false,
	},
}
