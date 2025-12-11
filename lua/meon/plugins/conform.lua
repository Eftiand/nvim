return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>fd",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			desc = "Format current buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			cs = { "csharpier" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
		},
	},
}
