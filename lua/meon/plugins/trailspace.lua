return {
  "echasnovski/mini.trailspace",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.trailspace").setup({
      -- Highlight only in modifiable buffers
      only_in_normal_buffers = true,
    })

    -- Optional: Add keymap to trim trailing spaces
    vim.keymap.set("n", "<leader>tw", function()
      require("mini.trailspace").trim()
    end, { desc = "Trim trailing whitespace" })

    -- Optional: Add keymap to trim last blank lines
    vim.keymap.set("n", "<leader>tW", function()
      require("mini.trailspace").trim_last_lines()
    end, { desc = "Trim last blank lines" })
  end,
}
