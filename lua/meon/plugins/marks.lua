return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  opts = {
    default_mappings = true,
    signs = true,
    mappings = {},
  },
  keys = {
    {
      "<leader>fm",
      function()
        local marks = {}
        for i = 65, 90 do -- A-Z
          local mark = string.char(i)
          local pos = vim.api.nvim_get_mark(mark, {})
          if pos[1] ~= 0 then
            local file = pos[4] ~= "" and pos[4] or vim.api.nvim_buf_get_name(0)
            table.insert(marks, string.format("%s:%d:%d:%s", file, pos[1], pos[2], mark))
          end
        end
        if #marks == 0 then
          vim.notify("No global marks set", vim.log.levels.INFO)
          return
        end
        require("fzf-lua").fzf_exec(marks, {
          prompt = "Global Marks❯ ",
          previewer = "builtin",
          actions = {
            ["default"] = function(selected)
              local parts = vim.split(selected[1], ":")
              local file, line = parts[1], tonumber(parts[2])
              vim.cmd("edit " .. file)
              vim.api.nvim_win_set_cursor(0, { line, 0 })
            end,
          },
        })
      end,
      desc = "Find global marks",
    },
    { "<leader>dm", "<cmd>delmarks A-Z0-9 | delmarks \"'[] | delmarks!<cr>", desc = "Delete all marks" },
  },
}
