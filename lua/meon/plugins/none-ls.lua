return {
	"nvimtools/none-ls.nvim",

	confi = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.gdformat,
			},
		})
	end,
}