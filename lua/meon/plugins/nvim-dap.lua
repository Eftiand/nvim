return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "Cliffback/netcoredbg-macOS-arm64.nvim",
  },
  config = function()
    local dap = require("dap")

    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    -- Load configurations from .vscode/launch.json (with JSON5 support)
    local vscode = require("dap.ext.vscode")
    vscode.json_decode = function(content)
      -- Remove // comments only outside of strings
      local result, in_string, i = {}, false, 1
      while i <= #content do
        local c = content:sub(i, i)
        if c == '"' and content:sub(i - 1, i - 1) ~= "\\" then
          in_string = not in_string
          table.insert(result, c)
        elseif not in_string and content:sub(i, i + 1) == "//" then
          while i <= #content and content:sub(i, i) ~= "\n" do
            i = i + 1
          end
        else
          table.insert(result, c)
        end
        i = i + 1
      end
      content = table.concat(result)
      -- Remove trailing commas
      while content:find(",(%s*[%]%}])") do
        content = content:gsub(",(%s*[%]%}])", "%1")
      end
      return vim.json.decode(content)
    end
    vscode.load_launchjs()

    vim.keymap.set("n", "<F5>", dap.continue)
    vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<F10>", dap.step_over)
    vim.keymap.set("n", "<F11>", dap.step_into)
    vim.keymap.set("n", "<F8>", dap.step_out)
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open DAP REPL" })
  end,
}
