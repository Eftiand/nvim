vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tab & indentation
opt.tabstop = 2
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

vim.opt.clipboard = "unnamedplus"

-- Ensure macOS clipboard provider is used
vim.g.clipboard = {
  name = 'macOS-clipboard',
  copy = {
    ['+'] = 'pbcopy',
    ['*'] = 'pbcopy',
  },
  paste = {
    ['+'] = 'pbpaste',
    ['*'] = 'pbpaste',
  },
  cache_enabled = 0,
}

opt.splitright = true
opt.splitbelow = true

-- Autosave on insert leave or when focus is lost
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
	pattern = "*",
	command = "silent! write",
})

-- Auto-reload files when changed externally
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	command = "checktime",
})

vim.api.nvim_create_user_command('Ofinder',
    function()
        local path = vim.api.nvim_buf_get_name(0)
        os.execute('open -R ' .. path)
    end,
    {}
)
