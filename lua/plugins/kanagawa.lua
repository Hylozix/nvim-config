-- 主题插件：只负责下载/安装；应用逻辑在 config/colorscheme.lua
return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  dependencies = { "folke/tokyonight.nvim" },
  config = function()
    require("config.colorscheme").setup()
  end,
}
