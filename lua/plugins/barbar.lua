-- 顶部标签页：打开的缓冲区一排标签（替代 bufferline）
-- 用 [b/]b 切换（故意不用 H/L，那俩你已经映射成行首/行尾了）
return {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim", -- 可选：标签上显示 git 状态
    "nvim-tree/nvim-web-devicons",
  },
  event = "VeryLazy",
  keys = {
    { "[b", "<cmd>BufferPrevious<cr>", desc = "上一个缓冲区" },
    { "]b", "<cmd>BufferNext<cr>", desc = "下一个缓冲区" },
    { "<leader>bd", "<cmd>BufferClose<cr>", desc = "关闭当前缓冲区" },
  },
  opts = {
    icons = {
      -- 标签上显示 LSP 诊断数（新 API；旧的 diagnostics 顶层选项已弃用）
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = { enabled = true },
        [vim.diagnostic.severity.WARN] = { enabled = true },
      },
    },
    -- 给文件树留出空位，标签不会被盖住
    sidebar_filetypes = {
      NvimTree = { text = "文件树" },
    },
  },
}
