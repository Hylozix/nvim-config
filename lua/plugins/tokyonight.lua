-- 主题插件（只负责下载/安装，不在这里应用 colorscheme）
return {
  "folke/tokyonight.nvim",
  lazy = true,
  opts = {
    dim_inactive = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = false },
    },
  },
}
