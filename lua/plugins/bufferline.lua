-- 顶部标签页：把打开的缓冲区显示成一排标签
-- 用 [b/]b 切换（故意不用 H/L，那俩你已经映射成行首/行尾了）
return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个缓冲区" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "下一个缓冲区" },
    { "<leader>bd", "<cmd>bdelete<cr>", desc = "关闭当前缓冲区" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp", -- 标签上显示 LSP 报错数
      -- 给文件树留出空位，标签不会被文件树盖住
      offsets = { { filetype = "NvimTree", text = "文件树", separator = true } },
    },
  },
}
