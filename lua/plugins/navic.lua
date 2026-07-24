-- 面包屑：状态栏显示当前所在 类 > 方法 > …（比 aerial 大纲侧栏轻得多）
-- 依赖 LSP documentSymbol，挂上语言服务器后自动出现
return {
  "SmiteshP/nvim-navic",
  lazy = true,
  opts = {
    highlight = true,
    depth_limit = 5, -- 层级太深时截断，避免状态栏被撑爆
    lsp = {
      auto_attach = true, -- LSP 附着时自动绑定，含 roslyn
    },
  },
}
