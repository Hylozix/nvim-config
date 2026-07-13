--语法高亮插件
return {
  -- 插件仓库地址
  "nvim-treesitter/nvim-treesitter",
  -- main = 唯一在维护的重写分支（旧 master 分支 2025 年已冻结，
  -- 在 Neovim 0.12 上会报 "attempt to call method 'range'" 等错误）。
  -- main 分支职责变简单了：只负责「安装解析器 + 提供查询文件」，
  -- 高亮/缩进的开启改由下面的 FileType 自动命令调用 Neovim 内置 API 完成。
  branch = "main",
  -- 插件更新时自动更新已安装的解析器
  build = ":TSUpdate",
  -- 懒加载：只有打开文件时才加载插件，不影响启动速度
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local ts = require("nvim-treesitter")

    -- Windows 上 tree-sitter CLI 编译解析器默认找 MSVC 的 cl.exe，
    -- 没装 Visual Studio 就会失败；没有 cl 时改用 gcc（scoop 的 mingw）
    if vim.fn.executable("cl") == 0 and vim.env.CC == nil then
      vim.env.CC = "gcc"
    end

    -- 需要安装的语言解析器，按需添加（异步下载编译，需要 gcc/zig 和 tree-sitter CLI）
    -- 注：markdown/lua/c/vim 等 Neovim 0.12 已自带，不用列在这里
    ts.install({
      "javascript",
      "typescript",
      "html",
      "css",
      "vue",
      "json",
      "bash",
      "python",
    })

    -- 打开文件时：有对应解析器就启用语法树高亮和缩进（pcall 保证没有解析器时静默跳过）
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        -- 文件类型 → 解析器语言名（比如 filetype=sh 对应解析器 bash）
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then return end
        if pcall(vim.treesitter.start, ev.buf, lang) then
          -- 基于语法树的智能缩进（等价于旧版的 indent = { enable = true }）
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
