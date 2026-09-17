return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- 图标依赖
    -- 懒加载：文件树不是每次开 nvim 都要用，之前它占了启动耗时的约四分之一
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen", "NvimTreeFocus" },
    keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<CR>",   desc = "开关文件树" },
        { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "定位当前文件" },
    },
    config = function()
        local skip_watch = {
            [".vs"] = true,
            [".git"] = true,
            ["node_modules"] = true,
            ["bin"] = true,
            ["obj"] = true,
            ["Release"] = true,
            ["Debug"] = true,
            ["app.publish"] = true,
            ["WinLib"] = true,
        }
        require("nvim-tree").setup({
            view = {
                width = { min = 32, max = "40%", padding = 2 },
            },
            renderer = {
                full_name = true,
                group_empty = true,
                indent_markers = { enable = true },
                highlight_git = true,
            },
            update_focused_file = { enable = true },
            -- 不监视这些目录的文件变动：都是工具自动高频写入的缓存/产物目录
            -- 用函数按目录名判断，避免 Windows 反斜杠让 vim 正则失效
            filesystem_watchers = {
                -- Windows 上 Git switch/checkout 会瞬间产生大量事件。
                -- 关闭阈值保护，交给 50ms debounce 合并后统一刷新，避免 watcher 被自动停用。
                max_events = 0,
                debounce_delay = 100,
                ignore_dirs = function(path)
                    return skip_watch[vim.fn.fnamemodify(path, ":t")] == true
                end,
            },
            reload_on_bufenter = true,
        })
    end,
}
