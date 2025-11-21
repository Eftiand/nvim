return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    select = {
      enabled = true,
      backend = { "fzf_lua", "builtin" },
    },
  },
}
