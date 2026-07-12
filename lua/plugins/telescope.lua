-- 模糊查找：找文件、全文搜索、切缓冲区……一天用几百次
-- 依赖命令行工具 ripgrep(rg) 做全文搜索：scoop install ripgrep
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "全文搜索（需 ripgrep）" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "已打开的缓冲区" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "帮助文档" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近打开的文件" },
  },
  -- 用函数形式：加载 telescope 时才求值，避免启动时 require 报错
  opts = function()
    return {
      defaults = {
        -- Esc 一次直接关闭（默认要按两次）
        mappings = { i = { ["<esc>"] = require("telescope.actions").close } },
      },
    }
  end,
}
