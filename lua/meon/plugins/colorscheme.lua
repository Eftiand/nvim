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

				--red = "#D19A66",
				--cyan = "#DE5D68",
			},
			highlights = {
				["@variable.member"] = { fg = "$red" },
				["@property"] = { fg = "$red" },
				["@lsp.type.property"] = { fg = "$red" },
			},
		})
		vim.cmd("colorscheme onedark")
	end,
}
