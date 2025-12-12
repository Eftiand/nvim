return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "Cliffback/netcoredbg-macOS-arm64.nvim",
    {
      "Weissle/persistent-breakpoints.nvim",
      opts = { load_breakpoints_event = { "BufReadPost" } },
    },
  },
  config = function()
    local dap = require("dap")

    -- Adapters
    dap.adapters.netcoredbg = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.adapters.coreclr = require("meon.util.vsdbg").get_adapter()

    -- Load configurations from .vscode/launch.json
    local vscode = require("dap.ext.vscode")
    vscode.json_decode = require("meon.util.json5").decode
    vscode.load_launchjs()

    -- Keymaps
    local pb = require("persistent-breakpoints.api")
    vim.keymap.set("n", "<F5>", dap.continue)
    vim.keymap.set("n", "<F8>", dap.step_out)
    vim.keymap.set("n", "<F9>", pb.toggle_breakpoint)
    vim.keymap.set("n", "<leader>db", pb.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>fb", function() require("dap").list_breakpoints() require("fzf-lua").quickfix() end, { desc = "Find breakpoints" })
    vim.keymap.set("n", "<F10>", dap.step_over)
    vim.keymap.set("n", "<F11>", dap.step_into)
    vim.keymap.set("n", "<leader>db", pb.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open DAP REPL" })
    vim.keymap.set("n", "<leader>de", function()
      local expr = vim.fn.input("Evaluate: ")
      if expr ~= "" then require("dapui").eval(expr, { enter = true }) end
    end, { desc = "Evaluate expression" })
    vim.keymap.set("n", "<leader>fb", function()
      dap.list_breakpoints()
      require("fzf-lua").quickfix()
    end, { desc = "Find breakpoints" })
    vim.keymap.set("n", "<S-F5>", function()
      require("dap.ui.widgets").centered_float(require("dap.ui.widgets").sessions)
    end, { desc = "Show debug sessions" })
  end,
}
