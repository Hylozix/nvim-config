-- LSP 进度提示：右下角显示「正在索引 / 加载中…」，避免干等不知道有没有挂上
return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    notification = {
      window = {
        winblend = 0, -- 和 Neovide/透明主题更合拍；不需要可删
      },
    },
  },
}
