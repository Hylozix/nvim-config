-- 屏内闪跳：按 s 后输入目标附近字符，再按高亮标签一跳到位
-- 比反复 hjkl / 搜索更适合大文件内挪动光标
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash 跳转",
    },
    {
      -- 故意不含 x（可视模式）：S 留给 surround「给选区加括号」
      "S",
      mode = { "n", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter 选区",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Flash 远程操作",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Flash Treesitter 搜索",
    },
  },
}
