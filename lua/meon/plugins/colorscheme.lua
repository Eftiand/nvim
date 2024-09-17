return {
	"navarasu/onedark.nvim",
	priority = 1000,
	config = function()
		require("onedark").setup({
			style = "warmer",
			transparent = true,
			colors = {
				bg0 = "#181A1F",
				purple = "#D55FDE",
				yellow = "#F5C876",
				blue = "#61AFEF",
				green = "#89CA78",
				cyan = "#58C1CF",
				red = "#EF596F",
				orange = "#F58838",
				dark_yellow = "#D19A66",

				--red = "#D19A66",
				--cyan = "#DE5D68",
			},
			highlights = {
				["@variable.member"] = { fg = "$red" },
				["@variable.parameter"] = { fg = "$dark_yellow" },
				["@property"] = { fg = "$red" },
				-- ["@constuctor"] = { fmt= "" },
				["@lsp.type.property"] = { fg = "$red" },
				["@lsp.type.parameter"] = { fg = "$dark_yellow" },
				["@lsp.type.interface"] = { fg = "$orange" },
				["@keyword.modifier.c_sharp"] = { fg = "$purple" },
				["@keyword.type.c_sharp"] = { fg = "$purple" },
				["@type.builtin"] = { fg = "$purple" },
				["@constant.builtin"] = { fg = "$purple" },
			},
		})
		vim.cmd("colorscheme onedark")
	end,
}
