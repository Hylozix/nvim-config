-- LSP：代码智能核心（跳转定义、报错提示、悬浮文档、重命名、补全能力）
-- 组成：mason 负责下载语言服务器 → mason-lspconfig 桥接 → nvim-lspconfig 配置
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        -- mason v2 起仓库从 williamboman/ 转交给 mason-org/，
        -- 旧地址已归档，现在只靠 GitHub 重定向工作，直接写新地址更稳
        "mason-org/mason.nvim", -- 语言服务器安装器（:Mason 打开面板），下面统一 setup
        "mason-org/mason-lspconfig.nvim",
        "saghen/blink.cmp",     -- 提供补全能力，注入到 LSP
    },
    config = function()
        -- 由 Mason 自动下载的服务器（换电脑会自动装）
        -- 注：C# 用 roslyn，由 plugins/roslyn.lua 单独驱动，不在这个列表里
        -- 注：clangd 不放这里——Mason 在部分平台（如 OCI ARM）无预编译包；改用系统 apt/dnf 的 clangd
        local mason_servers = {
            "lua_ls", "ts_ls", "html", "cssls", "jsonls", "bashls", "pyright",
            "rust_analyzer", -- Rust
            "marksman",      -- Markdown（标题跳转、链接补全、引用查找）
            "sqls",
        }

        require("mason").setup()
        -- mason-lspconfig v2 默认会给已安装的服务器调用 vim.lsp.enable()，
        -- 这里不要再 enable 一遍，否则会重复启动
        require("mason-lspconfig").setup({ ensure_installed = mason_servers })

        -- 用 blink.cmp 的补全能力扩展所有 LSP（这样补全才有 LSP 来源）
        vim.lsp.config("*", {
            capabilities = require("blink.cmp").get_lsp_capabilities(),
        })

        -- lua_ls：补全 vim.api / vim.fn，而不是只把 vim 当成未知全局变量
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                        checkThirdParty = false,
                        library = { vim.env.VIMRUNTIME },
                    },
                    hint = { enable = true },
                },
            },
        })

        -- 系统 clangd 不走 Mason，没装就别 enable，避免打开 C/C++ 文件时弹启动失败
        if vim.fn.executable("clangd") == 1 then
            vim.lsp.enable("clangd")
        end

        -- 只有某个缓冲区真正挂上 LSP 后，才绑定这些快捷键
        -- 不映射 gr / gi / K：nvim 0.11+ 已有全局默认
        --   grr 引用、gra 代码操作、grn 重命名、gri 实现、K 悬浮文档
        -- 再映射 gr 会变成前缀，导致 grr/gra/grn 每次都要等 timeoutlen
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
                local map = function(keys, fn, desc)
                    vim.keymap.set("n", keys, fn, { buffer = ev.buf, silent = true, desc = desc })
                end
                map("gd", vim.lsp.buf.definition, "跳转到定义")
                map("gD", vim.lsp.buf.declaration, "跳转到声明")
                map("<leader>k", vim.lsp.buf.hover, "悬浮文档") -- 与默认 K 相同，保留一个 leader 习惯键
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
