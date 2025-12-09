return {
  "mistricky/codesnap.nvim",
  lazy = true,
  keys = {
    { "<leader>cc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
  },
  opts = {
    has_breadcrumbs = false,
    bg_color = "#535c68",
    bg_x_padding = 50,
    bg_y_padding = 30,
  },
}
