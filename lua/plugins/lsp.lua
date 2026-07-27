-- LSP：代码智能核心（跳转定义、报错提示、悬浮文档、重命名、补全能力）
-- 组成：mason 负责下载语言服务器 → mason-lspconfig 桥接 → nvim-lspconfig 配置
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim", -- 语言服务器安装器（:Mason 打开面板），下面统一 setup
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp", -- 提供补全能力，注入到 LSP
  },
  config = function()
    -- 由 Mason 自动下载的服务器（换电脑会自动装）
    -- 注：C# 用 roslyn，由 plugins/roslyn.lua 单独驱动，不在这个列表里
    -- 注：clangd 不放这里——Mason 在部分平台（如 OCI ARM）无预编译包；改用系统 apt/dnf 的 clangd
    local mason_servers = {
      "lua_ls", "ts_ls", "html", "cssls", "jsonls", "bashls", "pyright",
      "rust_analyzer", -- Rust
      "marksman",      -- Markdown（标题跳转、链接补全、引用查找）
    }

    -- 系统包安装的服务器（不经过 Mason）
    local system_servers = {
      "clangd", -- C / C++：sudo apt install clangd / sudo dnf install clang-tools-extra
    }

    require("mason").setup()
    require("mason-lspconfig").setup({ ensure_installed = mason_servers })

    -- 用 blink.cmp 的补全能力扩展所有 LSP（这样补全才有 LSP 来源）
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    -- lua_ls 专属：告诉它 vim 是全局变量，并打开行内类型提示
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          hint = { enable = true },
        },
      },
    })

    -- 启用 Mason 列表 + 系统 clangd（走 PATH 里的 clangd）
    vim.lsp.enable(vim.list_extend(vim.deepcopy(mason_servers), system_servers))

    -- 只有某个缓冲区真正挂上 LSP 后，才绑定这些快捷键
    -- 注意：故意避开你已有的 H/J/K/L 导航键和 <leader>e（文件树）
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, silent = true, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "跳转到定义")
        map("gD", vim.lsp.buf.declaration, "跳转到声明")
        map("gr", vim.lsp.buf.references, "查找引用")
        map("gi", vim.lsp.buf.implementation, "跳转到实现")
        map("<leader>k", vim.lsp.buf.hover, "悬浮文档") -- 用 <leader>k，不抢你的 K=上移5行
        map("<leader>rn", vim.lsp.buf.rename, "重命名符号")
        map("<leader>ca", vim.lsp.buf.code_action, "代码操作/快速修复")
        map("<leader>d", vim.diagnostic.open_float, "查看当前行诊断")
        map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "上一个诊断")
        map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "下一个诊断")

        -- Inlay hints：行内显示类型/参数名（Neovim 内置，无需插件）
        -- 服务器不支持时静默跳过；<leader>ci 可临时关掉（觉得吵时）
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/inlayHint", ev.buf) then
          vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          map("<leader>ci", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
              { bufnr = ev.buf }
            )
          end, "切换 Inlay Hints")
        end
      end,
    })
  end,
}
