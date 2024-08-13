return {
	{
		"smoka7/hop.nvim",
		config = function()
			local hop = require("hop")
			local directions = require("hop.hint").HintDirection

			hop.setup({
				keys = "etovxqpdygfblzhckisuran", -- Customize these keys if needed
			})

			-- Define key mappings for hop
			vim.keymap.set("n", "<Leader>hf", function()
				hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
			end, { noremap = true, silent = true, desc = "Hop to character after cursor" })

			vim.keymap.set("n", "<Leader>hF", function()
				hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
			end, { noremap = true, silent = true, desc = "Hop to character before cursor" })

			vim.keymap.set("n", "<Leader>ht", function()
				hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
			end, { noremap = true, silent = true, desc = "Hop to character after cursor with hint offset -1" })

			vim.keymap.set("n", "<Leader>hT", function()
				hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
			end, { noremap = true, silent = true, desc = "Hop to character before cursor with hint offset 1" })
		end,
	},
}
