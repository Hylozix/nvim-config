-- 主题插件：只负责下载/安装；应用逻辑在 config/colorscheme.lua
return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  dependencies = { "folke/tokyonight.nvim" },
  config = function()
    require("kanagawa").setup({
      dimInactive = true, -- 非当前窗口略暗，分屏边界更清楚
      commentStyle = { italic = true },
      keywordStyle = { italic = false },
      statementStyle = { bold = true },
      colors = {
        theme = {
          all = {
            ui = { bg_gutter = "none" }, -- 行号列跟编辑区同色，少一条灰带
          },
        },
      },
    })
    require("config.colorscheme").setup()
  end,
}
