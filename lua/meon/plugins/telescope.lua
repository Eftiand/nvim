return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				-- Performance optimizations
				file_ignore_patterns = {
					"%.git/",
					"node_modules/",
					"%.cache/",
					"build/",
					"dist/",
					"target/",
					"vendor/",
					"%.next/",
					"%.nuxt/",
					"%.output/",
					"%.venv/",
					"__pycache__/",
					"%.terraform/",
					"%.DS_Store",
				},
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
				},
				-- Disable preview for large files
				preview = {
					timeout = 200,
					filesize_limit = 1, -- MB
					treesitter = false, -- Disable treesitter highlighting in preview for speed
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-u>"] = false, -- clear prompt on ctrl-u instead of scrolling
					},
				},
				cache_picker = {
					num_pickers = 20, -- Increased cache
					limit_entries = 2000, -- Increased cache entries
				},
			},
			pickers = {
				find_files = {
					-- Use fd for faster file finding (install with: brew install fd)
					find_command = {
						"fd",
						"--type",
						"f",
						"--hidden",
						"--strip-cwd-prefix",
						"--exclude",
						".git",
						"--exclude",
						"node_modules",
						"--exclude",
						"build",
						"--exclude",
						"dist",
						"--exclude",
						"target",
						"--exclude",
						".next",
						"--exclude",
						".cache",
					},
					-- Alternative if you don't have fd: use rg
					-- find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
					-- Only show results after typing at least 2 characters
					on_input_filter_cb = function(prompt)
						return { prompt = prompt }
					end,
				},
				live_grep = {
					-- Improve live_grep performance
					on_input_filter_cb = function(prompt)
						-- Only search after typing at least 3 characters
						if #prompt < 3 then
							return { prompt = "" }
						end
						return { prompt = prompt }
					end,
				},
			},
		})

		telescope.load_extension("fzf")

		local default_opts = { noremap = true, silent = true } -- Default options
		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set(
			"n",
			"<leader>fa",
			"<cmd>lua require'telescope.builtin'.find_files({ hidden = true, no_ignore = true, file_ignore_patterns = { '.git/' } })<cr>",
			{ desc = "Fuzzy find all files" }
		)
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
	end,
}
