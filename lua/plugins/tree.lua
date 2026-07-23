return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- 图标依赖
    config = function()
        require("nvim-tree").setup({
            view = { width = 30 },
            renderer = { group_empty = true },
            -- 不监视这些目录的文件变动：都是工具自动高频写入的缓存/产物目录，
            -- 监视它们没意义，还会触发"事件过多，关闭监视器"的警告
            -- （Visual Studio 的 .vs、构建产物 bin/obj、git 内部、node_modules）
            -- 注意：每一项是 vim 正则，拿来匹配目录的「绝对路径」
            -- \> 是单词右边界，防止 .vs 误伤 .vscode、bin 误伤 binary 之类
            -- [/\\] 同时兼容正反斜杠路径分隔符
            filesystem_watchers = {
                -- ignore_dirs = {
                --     "\\.vs\\>",      -- Visual Studio 缓存目录（这次警告的来源）
                --     "\\.git\\>",     -- git 内部目录
                --     "node_modules",  -- 前端依赖
                --     "[/\\\\]bin\\>", -- 构建产物
                --     "[/\\\\]obj\\>", -- C# 编译中间产物
                -- },
                ignore_dirs = {
                    "\\.vs\\>",
                    "\\.git\\>",
                    "node_modules",
                    "[/\\\\]bin\\>",
                    "[/\\\\]obj\\>",
                    "[/\\\\]Release\\>",       -- 发布/编译输出
                    "[/\\\\]Debug\\>",         -- 调试输出（建议一并忽略）
                    "[/\\\\]app\\.publish\\>", -- 这次警告的目录
                    "[/\\\\]WinLib\\>",        -- 可选：整个 WinLib 都不监视
                },
            },
        })
        -- 插件专属快捷键写在插件自己的 config 里
        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { noremap = true, silent = true })
    end,
}
