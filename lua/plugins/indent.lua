-- 缩进参考线：每一级缩进画一条竖线，代码层级一目了然
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl", -- 这个插件的模块名是 ibl，不是仓库名
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    indent = { char = "│" },
    scope = { enabled = true }, -- 高亮当前所在的缩进块
  },
}
