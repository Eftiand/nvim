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

    local function get_project_root()
      -- Try to find project root via git
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if vim.v.shell_error == 0 and git_root and git_root ~= "" then
        return git_root
      end
      -- Fallback to cwd
      return vim.fn.getcwd()
    end

    local function parse_launch_json()
      local root = get_project_root()
      local launch_path = root .. "/.vscode/launch.json"
      if vim.fn.filereadable(launch_path) == 0 then
        vim.notify("launch.json not found at: " .. launch_path, vim.log.levels.WARN)
        return nil
      end

      local content = table.concat(vim.fn.readfile(launch_path), "\n")
      -- Strip single-line comments (// ...) but not inside strings
      content = content:gsub("(%s)//.-[\r\n]", "%1\n")
      content = content:gsub("^//.-[\r\n]", "\n")
      -- Strip block comments
      content = content:gsub("/%*.-%*/", "")
      -- Handle trailing commas (common in JSONC)
      content = content:gsub(",%s*}", "}")
      content = content:gsub(",%s*%]", "]")

      local ok, json = pcall(vim.json.decode, content)
      if not ok then
        vim.notify("Failed to parse launch.json: " .. tostring(json), vim.log.levels.ERROR)
        return nil
      end
      return json
    end

    local function get_task_spec(config)
      local cwd = get_project_root()

      local function resolve_path(path)
        if not path then return nil end
        return path:gsub("%${workspaceFolder}", cwd)
      end

      -- Handle coreclr/dotnet with program (DLL)
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
        }
      -- Handle dotnet with projectPath
      elseif config.type == "dotnet" and config.projectPath then
        local project = resolve_path(config.projectPath)
        return {
          name = config.name,
          cmd = { "dotnet", "run", "--project", project },
          cwd = cwd,
        }
      -- Handle runtimeExecutable
      elseif config.runtimeExecutable then
        local args = { config.runtimeExecutable }
        for _, arg in ipairs(config.runtimeArgs or {}) do
          table.insert(args, arg)
        end
        return {
          name = config.name,
          cmd = args,
          cwd = resolve_path(config.cwd) or cwd,
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
