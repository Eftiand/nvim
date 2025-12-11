vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Reload config
keymap.set("n", "<leader>rr", "<cmd>source ~/.config/nvim/init.lua<CR>", { desc = "Reload Neovim config" })

-- window management
keymap.set("n", "sh", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "sv", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>ta", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- Terminal keymaps (using 'ft' prefix for 'floating terminal')
keymap.set("n", "<leader>tt", "<cmd>terminal<CR>", { desc = "Open terminal in new buffer" })
keymap.set("n", "<leader>th", "<cmd>split | terminal<CR>", { desc = "Open terminal in horizontal split" })
keymap.set("n", "<leader>tv", "<cmd>vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })

-- Terminal window navigation (works in all terminal buffers except fzf-lua)
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      if vim.bo.filetype == "fzf" then return end

      local opts = { buffer = 0, silent = true }
      vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
      vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
      vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
      vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
    end, 10)
  end,
})

-- Build
keymap.set("n", "<leader>bp", function()
  local settings_path = vim.fn.getcwd() .. "/.vscode/settings.json"
  local solution = nil

  -- Try to read from .vscode/settings.json
  if vim.fn.filereadable(settings_path) == 1 then
    local content = table.concat(vim.fn.readfile(settings_path), "\n")
    -- Strip // comments and /* */ block comments (JSONC)
    content = content:gsub("//.-\n", "\n"):gsub("/%*.-%*/", "")
    local ok, json = pcall(vim.json.decode, content)
    if ok and json and json["dotnet.defaultSolution"] then
      solution = json["dotnet.defaultSolution"]
    end
  end

  -- Fallback: find .sln or .slnx in cwd
  if not solution then
    local files = vim.fn.glob("*.sln", false, true)
    vim.list_extend(files, vim.fn.glob("*.slnx", false, true))
    if #files > 0 then
      solution = files[1]
    end
  end

  local cmd = solution and ("dotnet build " .. solution) or "dotnet build"
  local output = {}
  local start_time = vim.uv.hrtime()
  local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local spinner_idx = 1
  local timer = vim.uv.new_timer()

  vim.api.nvim_echo({ { spinner[1] .. " Building...", "WarningMsg" } }, false, {})
  vim.cmd("redraw")

  timer:start(80, 80, vim.schedule_wrap(function()
    spinner_idx = spinner_idx % #spinner + 1
    vim.api.nvim_echo({ { spinner[spinner_idx] .. " Building...", "WarningMsg" } }, false, {})
    vim.cmd("redraw")
  end))

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then vim.list_extend(output, data) end
    end,
    on_stderr = function(_, data)
      if data then vim.list_extend(output, data) end
    end,
    on_exit = function(_, code)
      timer:stop()
      timer:close()
      local elapsed = (vim.uv.hrtime() - start_time) / 1e9
      vim.schedule(function()
        -- Parse dotnet build output: path/file.cs(line,col): error CS1234: message
        vim.fn.setqflist({}, " ", {
          title = "dotnet build",
          lines = output,
          efm = "%f(%l\\,%c): %trror %m,%-G%.%#",
        })
        if code == 0 then
          vim.api.nvim_echo({ { string.format("Build succeeded (%.1fs)", elapsed), "DiagnosticOk" } }, false, {})
        else
          vim.notify(string.format("Build failed (%.1fs) - :copen for errors", elapsed), vim.log.levels.ERROR)
          vim.cmd("copen")
        end
      end)
    end,
  })
end, { desc = "Build project" })
