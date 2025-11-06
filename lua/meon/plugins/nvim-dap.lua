return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local dap = require("dap")

    local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

    local netcoredbg_adapter = {
      type = "executable",
      command = mason_path,
      args = { "--interpreter=vscode" },
    }

    dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
    dap.adapters.coreclr = netcoredbg_adapter    -- needed for unit test debugging

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net10.0/", "file")
        end,
      },
    }

    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", opts)
    map("n", "<F6>", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
    map("n", "<F9>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
    map("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", opts)
    map("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", opts)
    map("n", "<F8>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
    map("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", opts)
    map("n", "<leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", opts)
    map("n", "<leader>dt", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>",
      { noremap = true, silent = true, desc = 'debug nearest test' })
  end,
}
