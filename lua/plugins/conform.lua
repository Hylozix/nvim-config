-- 格式化：保存时自动格式化代码
-- 开箱即用走 LSP 自带的格式化；想用 stylua/prettier/black 这类专业格式化器，
-- 进 nvim 跑 :Mason 装好后，把下面对应行的注释去掉即可。
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      cs = { "csharpier" },
    },
    -- 保存时格式化；没有配置专用格式化器时，回退用 LSP 的格式化能力
    format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
  },
}
