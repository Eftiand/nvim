return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    select = {
      enabled = true,
      backend = { "builtin", "fzf_lua" },
    },
  },
}
