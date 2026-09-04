-- 顶部标签栏：文件类型图标 + 扩展名 + 左侧青色竖条标当前项
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
    hide = { extensions = false },
    icons = {
      button = false,
      filetype = { enabled = true },
      separator = { left = "▎", right = " " },
      inactive = { separator = { left = "▎", right = " " } },
    },
    -- 打开 nvim-tree 时标签栏右移，避免和文件树叠在一起
    sidebar_filetypes = {
      NvimTree = { text = "Files", align = "center" },
    },
    minimum_padding = 1,
    maximum_length = 22,
  },
}
