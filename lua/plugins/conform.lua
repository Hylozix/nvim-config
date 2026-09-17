-- 格式化：保存时自动格式化代码
-- 优先用 formatters_by_ft 里指定的格式化器（:Mason 或 dotnet tool 装），
-- 没装/没配的语言自动回退到 LSP 自带的格式化能力。
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
  keys = {
    {
      "<leader>cF",
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        require("conform").format({
          async = true,
          -- Roslyn's Razor formatter can return ranges from a stale generated
          -- document, which makes the server reject the edit as out of bounds.
          lsp_format = vim.bo[bufnr].filetype == "razor" and "never" or "fallback",
        })
      end,
      mode = { "n", "v" },
      desc = "手动格式化",
    },
  },
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
      sql = { "sql_formatter" },
    },
    -- 保存时格式化；没有配置专用格式化器时，回退用 LSP 的格式化能力
    -- csharpier / black 在大文件上 500ms 经常超时；没装对应 formatter 时不要反复弹窗
    -- 写成函数是为了能临时关掉：改别人的代码库时，自动格式化会把整个文件搅成大 diff
    format_on_save = function(bufnr)
      if
        vim.g.disable_autoformat
        or vim.b[bufnr].disable_autoformat
        or vim.b[bufnr].large_file
        or vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) > 1024 * 1024
        or vim.bo[bufnr].filetype == "razor"
      then
        return
      end
      return { timeout_ms = 1500, lsp_format = "fallback" }
    end,
    notify_no_formatters = false,
  },
  config = function(_, opts)
    require("conform").setup(opts)

    -- :FormatDisable 关全局，:FormatDisable! 只关当前缓冲区
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = "关闭保存时自动格式化", bang = true })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "开启保存时自动格式化" })
  end,
}
