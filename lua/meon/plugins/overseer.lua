return {
  "stevearc/overseer.nvim",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  config = function()
    local overseer = require("overseer")

    overseer.setup({
      dap = true,
      strategy = "terminal",
      templates = { "builtin" },
      task_list = {
        direction = "right",
        default_detail = 2,
      },
    })

    local function parse_launch_json()
      local launch_path = vim.fn.getcwd() .. "/.vscode/launch.json"
      if vim.fn.filereadable(launch_path) == 0 then
        return nil
      end

      local content = table.concat(vim.fn.readfile(launch_path), "\n")
      content = content:gsub("//.-\n", "\n")
      content = content:gsub("/%*.-%*/", "")

      local ok, json = pcall(vim.json.decode, content)
      if ok then
        return json
      end
      return nil
    end

    local function get_task_spec(config)
      local cwd = vim.fn.getcwd()

      if config.type == "dotnet" and config.projectPath then
        local project = config.projectPath:gsub("%${workspaceFolder}", cwd)
        return {
          name = config.name,
          cmd = { "dotnet", "run", "--project", project },
          cwd = cwd,
        }
      elseif config.runtimeExecutable then
        local args = { config.runtimeExecutable }
        for _, arg in ipairs(config.runtimeArgs or {}) do
          table.insert(args, arg)
        end
        return {
          name = config.name,
          cmd = args,
          cwd = config.cwd and config.cwd:gsub("%${workspaceFolder}", cwd) or cwd,
        }
      end
      return nil
    end

    local function run_task(name)
      local json = parse_launch_json()
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

      -- Check if it's a compound
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
      local json = parse_launch_json()
      if not json then
        vim.notify("No launch.json found", vim.log.levels.ERROR)
        return
      end

      local items = {}

      -- Add compounds first
      for _, compound in ipairs(json.compounds or {}) do
        table.insert(items, "[Compound] " .. compound.name)
      end

      -- Add individual configs
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
        local json = parse_launch_json()
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
