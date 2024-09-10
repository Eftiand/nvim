return {
	{
		"ggandor/leap.nvim",
		config = function()
			local leap = require("leap")
			leap.add_default_mappings() -- This is optional if you want default mappings.

			-- Custom key mappings for leap using correct API
			vim.keymap.set("n", "f", function()
				leap.leap({ target_windows = { vim.api.nvim_get_current_win() } })
			end, { desc = "Leap forward" })
			vim.keymap.set("n", "F", function()
				leap.leap({ backward = true, target_windows = { vim.api.nvim_get_current_win() } })
			end, { desc = "Leap backward" })
		end,
	},
}
