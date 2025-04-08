return {
	{
		"ggandor/leap.nvim",
		config = function()
			local leap = require("leap")
			vim.keymap.set("n", "f", function()
				leap.leap({ target_windows = { vim.api.nvim_get_current_win() } })
			end, { desc = "Leap forward" })
			vim.keymap.set("n", "F", function()
				leap.leap({ backward = true, target_windows = { vim.api.nvim_get_current_win() } })
			end, { desc = "Leap backward" })
		end,
	},
}
