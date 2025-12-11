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
    vscode.json_decode = require("meon.util.json5").decode
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
