return {
  "mfussenegger/nvim-dap",
  lazy = false,
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

    -- Python adapter (debugpy)
    local python_adapter = function(cb, config)
      if config.request == "attach" then
        local port = (config.connect or config).port
        local host = (config.connect or config).host or "127.0.0.1"
        cb({ type = "server", port = assert(port, "port required for attach"), host = host })
      else
        cb({
          type = "executable",
          command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
          args = { "-m", "debugpy.adapter" },
        })
      end
    end
    dap.adapters.python = python_adapter
    dap.adapters.debugpy = python_adapter

    -- Load configurations from .vscode/launch.json
    local vscode = require("dap.ext.vscode")
    vscode.json_decode = require("meon.util.json5").decode

    -- Helper to reload launch.json
    local function load_launchjs()
      vscode.load_launchjs(nil, { python = { "python" }, debugpy = { "python" } })
    end

    -- Load on startup if exists
    load_launchjs()

    -- Auto-reload launch.json on directory change
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        -- Clear existing configurations for filetypes that use launch.json
        dap.configurations.python = nil
        dap.configurations.debugpy = nil
        load_launchjs()
      end,
    })

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
    vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate debug session" })
    vim.keymap.set("n", "<leader>dl", function()
      dap.configurations.python = nil
      dap.configurations.debugpy = nil
      load_launchjs()
      vim.notify("Reloaded launch.json", vim.log.levels.INFO)
    end, { desc = "Reload launch.json" })
  end,
}
