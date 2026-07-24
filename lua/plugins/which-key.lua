-- 按键提示：按下 <leader> 等前缀键后，弹窗列出可用的后续按键
-- 对还在记快捷键的阶段特别友好
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 前缀分组的名字，弹窗里会显示成一类
    spec = {
      { "<leader>f", group = "查找 (find)" },
      { "<leader>h", group = "Git hunk" },
      { "<leader>c", group = "代码 (code)" },
      { "<leader>b", group = "缓冲区 (buffer)" },
      { "<leader>t", group = "主题 (theme)" },
    },
  },
}
