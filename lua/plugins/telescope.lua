-- 模糊查找：找文件、全文搜索、切缓冲区……一天用几百次
-- 依赖命令行工具 ripgrep(rg) 做全文搜索：scoop install ripgrep
-- fzf-native：C 实现的排序/匹配，输入过滤比默认 Lua sorter 跟手
return {
  "nvim-telescope/telescope.nvim",
  -- 用 master 活跃分支：旧的 0.1.x 分支停更了，其预览器还在调用
  -- nvim-treesitter master 才有的 ft_to_lang()，和 main 分支一起用会报错
  branch = "master",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- Windows + scoop mingw：必须指定 MinGW Makefiles，否则 cmake 会找 nmake 失败
      build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -G "MinGW Makefiles" && cmake --build build --config Release && cmake --install build --prefix build',
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "全文搜索（需 ripgrep）" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "已打开的缓冲区" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "帮助文档" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近打开的文件" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        -- Esc 一次直接关闭（默认要按两次）
        mappings = { i = { ["<esc>"] = require("telescope.actions").close } },
      },
    })
    -- 编译失败时不报错卡死，只是继续用默认 sorter
    pcall(require("telescope").load_extension, "fzf")
  end,
}
