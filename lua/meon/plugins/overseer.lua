return {
  "stevearc/overseer.nvim",
  config = function()
    local overseer = require("overseer")
    local json_decode = require("meon.util.json5").decode

    overseer.setup({
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
      return json_decode(content)
    end

    local function get_task_spec(config)
      local cwd = get_project_root()

      local function resolve_path(path)
        if not path then return nil end
        return path:gsub("%${workspaceFolder}", cwd):gsub("%${file}", vim.fn.expand("%:p"))
      end

      local function get_runtime(program)
        if not program then return nil end
        local ext = program:match("%.([^.]+)$")
        local runtimes = {
          py = { "python" }, js = { "node" }, ts = { "npx", "ts-node" }, rb = { "ruby" },
          pl = { "perl" }, php = { "php" }, lua = { "lua" }, sh = { "bash" },
          dll = { "dotnet" }, go = { "go", "run" },
        }
        return runtimes[ext]
      end

      local cmd = {}

      -- 1. Explicit runtime executable
      if config.runtimeExecutable then
        table.insert(cmd, resolve_path(config.runtimeExecutable) or config.runtimeExecutable)
        for _, arg in ipairs(config.runtimeArgs or {}) do
          table.insert(cmd, arg)
        end

      -- 2. Cargo (Rust) - has nested build config
      elseif config.cargo then
        cmd = { "cargo", "run" }
        for _, arg in ipairs(config.cargo.args or {}) do
          if arg ~= "build" and arg ~= "test" then
            table.insert(cmd, arg)
          end
        end

      -- 3. Module-based (python -m, etc)
      elseif config.module then
        table.insert(cmd, resolve_path(config.python) or "python")
        table.insert(cmd, "-m")
        table.insert(cmd, config.module)

      -- 4. Program with auto-detected or explicit runtime
      elseif config.program then
        local program = resolve_path(config.program) or config.program
        if config.python then
          table.insert(cmd, resolve_path(config.python))
        else
          local runtime = get_runtime(program)
          if runtime then
            for _, part in ipairs(runtime) do
              table.insert(cmd, part)
            end
          end
        end
        table.insert(cmd, program)

      -- 5. Project path (.NET style)
      elseif config.projectPath then
        cmd = { "dotnet", "run", "--project", resolve_path(config.projectPath) or config.projectPath }

      else
        return nil
      end

      -- Add args
      for _, arg in ipairs(config.args or {}) do
        table.insert(cmd, arg)
      end

      return {
        name = config.name,
        cmd = cmd,
        cwd = resolve_path(config.cwd) or cwd,
        env = config.env,
      }
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
