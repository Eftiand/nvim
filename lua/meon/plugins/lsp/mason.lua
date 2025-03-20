return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls", -- TypeScript/JavaScript
				"cssls", -- CSS
				"html", -- HTML
			},
		})
		mason_tool_installer.setup({
			ensure_installed = {
				"eslint", -- JavaScript linter
				"html", -- HTML
				"jsonls", -- JSON
				"prettier", -- prettier formatter
				"stylua",
				"csharp-language-server",
				"netcoredbg",
			},
		})
	end,
}
