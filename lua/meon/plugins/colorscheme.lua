return {
	"navarasu/onedark.nvim",
	priority = 1000,
	config = function()
		require("onedark").setup({
			style = "warmer",
			colors = {
				bg0 = "#181A1F",
				purple = "#D55FDE",
				yellow = "#F5C876",
				blue = "#61AFEF",
				green = "#89CA78",
				cyan = "#58C1CF",
				red = "#EF596F",
			},
		})
		vim.cmd("colorscheme onedark")
	end,
}
