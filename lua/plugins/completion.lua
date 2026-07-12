-- 自动补全：blink.cmp（比 nvim-cmp 更快，自带预编译二进制免装 Rust）
return {
  "saghen/blink.cmp",
  version = "1.*", -- 用 release tag，会自动下载预编译好的模糊匹配二进制
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" }, -- 常用代码片段库
  opts = {
    -- 键位预设：<C-y> 确认，<C-space> 手动触发，<C-e> 关闭，方向键上下选
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    -- 补全来源：LSP、路径、代码片段、当前缓冲区词
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = {
      -- 选中补全项时在旁边显示文档
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
