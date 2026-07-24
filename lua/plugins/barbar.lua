-- 顶部标签：按 ilovevim 的 barbar 配置
-- （他已弃用 mini.tabline，注释写着「改用 barbar.nvim」）
return {
  "romgrk/barbar.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  keys = {
    { "[b", "<cmd>BufferPrevious<cr>", desc = "上一个缓冲区" },
    { "]b", "<cmd>BufferNext<cr>", desc = "下一个缓冲区" },
    { "<leader>bd", "<cmd>BufferClose<cr>", desc = "关闭当前缓冲区" },
  },
  opts = {
    animation = false,
    hide = { extensions = true }, -- 只显示 init，不显示 init.lua
    icons = {
      button = false, -- 不要关闭按钮
      filetype = { custom_colors = true, enabled = false }, -- 不要文件类型图标
      -- 分隔符默认为 ▎（细竖条），右边界空格，就是参考图那种分割感
      separator = { right = " " },
      inactive = { separator = { right = " " } },
    },
    minimum_padding = 0,
    maximum_length = 14,
  },
}
