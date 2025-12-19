return {
  "mistricky/codesnap.nvim",
  tag = "v2.0.0-beta.16",
  lazy = true,
  keys = {
    { "<leader>cc", ":'<,'>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
  },
  config = function()
    require("codesnap").setup({
      snapshot_config = {
        theme = "candy",
        background = "#00000000",
        padding_x = 20,
        padding_y = 20,
        watermark = {
          content = "",
        },
      },
    })
  end,
}
