--语法高亮插件
return {
  -- 插件仓库地址
  "nvim-treesitter/nvim-treesitter",
  -- 关键：锁定 master 稳定分支。
  -- nvim-treesitter 有两个不兼容的分支：
  --   master = 经典版（require("nvim-treesitter.configs") 这套 API，也就是下面用的）
  --   main   = 重写版（API 完全不同，没有 configs 模块）
  -- 不写这一行时 lazy 会拉到 main，导致 require 报错、插件加载失败。
  branch = "master",
  -- 安装/更新时自动执行编译命令，更新语法解析器
  build = ":TSUpdate",
  -- 懒加载：只有打开文件时才加载插件，不影响启动速度
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- 指定编译解析器时优先使用的编译器（有哪个用哪个）。
    -- Windows 上推荐装 zig：winget install zig.zig  （单文件、免配置）
    require("nvim-treesitter.install").compilers = { "zig", "clang", "gcc", "cc", "cl" }

    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      -- 自动安装的语言解析器，按需添加你常用的语言
      -- 支持的完整语言列表可查 nvim-treesitter 官方仓库
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "html",
        "css",
        "vue",
        "json",
        "bash",
        "python",
      },

      -- 打开未安装解析器的文件时，自动下载安装
      auto_install = true,

      -- 核心：开启语法树高亮
      highlight = {
        enable = true,
        -- 关闭老旧的正则高亮，避免双重高亮导致颜色错乱
        additional_vim_regex_highlighting = false,
      },

      -- 开启基于语法树的智能缩进
      indent = { enable = true },

      -- 增量选择（可选）：按回车逐步扩大选中范围，按退格缩小
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",    -- 回车开始选中
          node_incremental = "<CR>",  -- 回车扩大选中范围
          node_decremental = "<BS>",  -- 退格缩小选中范围
        },
      },
    })
  end,
}
