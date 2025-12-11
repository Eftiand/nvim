return {
  "stevearc/overseer.nvim",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  config = function()
    local overseer = require("overseer")
    local vscode = require("dap.ext.vscode")

    overseer.setup({
      dap = true,
      strategy = "terminal",
      templates = { "builtin" },
      task_list = {
        direction = "right",
        default_detail = 2,
      },
    })

    local function get_project_root()
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if vim.v.shell_error == 0 and git_root and git_root ~= "" then
        return git_root
      end
      return vim.fn.getcwd()
    end

    local function load_launch_json()
      local root = get_project_root()
      local launch_path = root .. "/.vscode/launch.json"
      if vim.fn.filereadable(launch_path) == 0 then
        return nil
      end
      local content = table.concat(vim.fn.readfile(launch_path), "\n")
      return vscode.json_decode(content)
    end

    local function get_task_spec(config)
      local cwd = get_project_root()

      local function resolve_path(path)
        if not path then return nil end
        return path:gsub("%${workspaceFolder}", cwd)
      end

      if (config.type == "coreclr" or config.type == "dotnet") and config.program then
        local program = resolve_path(config.program)
        local task_cwd = resolve_path(config.cwd) or cwd
        local cmd = { "dotnet", program }
        for _, arg in ipairs(config.args or {}) do
          table.insert(cmd, arg)
        end
        return {
          name = config.name,
          cmd = cmd,
          cwd = task_cwd,
          env = config.env,
        }
      elseif config.type == "dotnet" and config.projectPath then
        local project = resolve_path(config.projectPath)
        return {
          name = config.name,
          cmd = { "dotnet", "run", "--project", project },
          cwd = cwd,
          env = config.env,
        }
      elseif config.runtimeExecutable then
        local args = { config.runtimeExecutable }
        for _, arg in ipairs(config.runtimeArgs or {}) do
          table.insert(args, arg)
        end
        return {
          name = config.name,
          cmd = args,
          cwd = resolve_path(config.cwd) or cwd,
          env = config.env,
        }
      end
      return nil
    end

    local function run_task(name)
      local json = load_launch_json()
      if not json then
        vim.notify("No launch.json found", vim.log.levels.ERROR)
        return
      end

      for _, config in ipairs(json.configurations or {}) do
        if config.name == name then
          local spec = get_task_spec(config)
          if spec then
            overseer.new_task(spec):start()
            overseer.open()
          end
          return
        end
      end

      for _, compound in ipairs(json.compounds or {}) do
        if compound.name == name then
          local configs = {}
          for _, c in ipairs(json.configurations or {}) do
            configs[c.name] = c
          end

          for _, config_name in ipairs(compound.configurations) do
            local config = configs[config_name]
            if config then
              local spec = get_task_spec(config)
              if spec and spec.cmd then
                overseer.new_task(spec):start()
              else
                vim.notify("Skipping unsupported config: " .. config_name, vim.log.levels.WARN)
              end
            else
              vim.notify("Config not found: " .. config_name, vim.log.levels.WARN)
            end
          end
          overseer.open()
          return
        end
      end

      vim.notify("Task not found: " .. name, vim.log.levels.ERROR)
    end

    local function select_and_run()
      local json = load_launch_json()
      if not json then
        vim.notify("No launch.json found", vim.log.levels.ERROR)
        return
      end

      local items = {}

      for _, compound in ipairs(json.compounds or {}) do
        table.insert(items, "[Compound] " .. compound.name)
      end

      for _, config in ipairs(json.configurations or {}) do
        if config.request == "launch" and config.name then
          local spec = get_task_spec(config)
          if spec then
            table.insert(items, config.name)
          end
        end
      end

      vim.ui.select(items, { prompt = "Select task:" }, function(choice)
        if choice then
          local name = choice:gsub("^%[Compound%] ", "")
          run_task(name)
        end
      end)
    end

    vim.api.nvim_create_user_command("LaunchTask", function(opts)
      if opts.args and opts.args ~= "" then
        run_task(opts.args)
      else
        select_and_run()
      end
    end, {
      nargs = "?",
      complete = function()
        local json = load_launch_json()
        if not json then return {} end
        local names = {}
        for _, c in ipairs(json.compounds or {}) do
          table.insert(names, c.name)
        end
        for _, c in ipairs(json.configurations or {}) do
          if c.name then
            table.insert(names, c.name)
          end
        end
        return names
      end,
    })

    local map = vim.keymap.set

    map("n", "<leader>or", select_and_run, { desc = "Run task" })
    map("n", "<leader>ot", "<Cmd>OverseerToggle<CR>", { desc = "Toggle task list" })
    map("n", "<leader>oa", "<Cmd>OverseerTaskAction<CR>", { desc = "Task action" })
  end,
}
