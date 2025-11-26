return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			debug = true,
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.gdformat,
				null_ls.builtins.formatting.csharpier,
				null_ls.builtins.formatting.prettier,
			},
			-- Disable automatic formatting
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					-- Set up a keymap for manual formatting only
					vim.keymap.set("n", "<leader>fd", function()
						vim.lsp.buf.format({ bufnr = bufnr })
					end, { buffer = bufnr, desc = "Format current buffer" })
				end
			end,
		})
	end,
}
