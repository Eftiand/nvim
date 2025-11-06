return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		require("claudecode").setup()

		-- Custom function to send and focus
		vim.keymap.set("v", "<C-i>", function()
			vim.cmd("ClaudeCodeSend")
			vim.schedule(function()
				vim.cmd("ClaudeCodeFocus")
			end)
		end, { desc = "Send to Claude and focus" })
	end,
	keys = {
		{ "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Cl_C_Caude", mode = "t" }, -- Works in terminal mode
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{
			"<C-i>",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
		},
		-- Diff management
		{ "<C-i>", "<cmd>ClaudeCodeSend<cr><cmd>ClaudeCodeFocus<cr>", desc = "Send to Claude", mode = "v" },
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	},
}
