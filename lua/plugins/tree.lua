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
            [".svn"] = true, -- 每次 svn 命令都会写 wc.db，pristine 下还有 256 个子目录
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
            -- 默认只等 400ms，累计 5 次超时会关闭本次会话的 Git 集成。
            -- 给 Windows 上的仓库扫描留出余量，避免偶发变慢后标记一直失效。
            git = {
                enable = true,
                timeout = 2000,
            },
            -- 不监视这些目录的文件变动：都是工具自动高频写入的缓存/产物目录
            -- 用函数按目录名判断，避免 Windows 反斜杠让 vim 正则失效
            filesystem_watchers = {
                -- Windows 上 Git switch/checkout 会瞬间产生大量事件。
                -- 关闭阈值保护，交给 100ms debounce 合并后统一刷新，避免 watcher 被自动停用。
                max_events = 0,
                debounce_delay = 100,
                ignore_dirs = function(path)
                    -- 只看文件树根目录以下的部分：根目录本身位于 bin、Release 之类目录里时，
                    -- 不能因此整棵树都不监视
                    local root = require("nvim-tree.core").get_cwd()
                    if root and path:sub(1, #root) == root then
                        path = path:sub(#root + 1)
                    end
                    -- 任意一层命中就跳过：nvim-tree 对每个子目录单独调用这里，
                    -- 只看最后一段的话 .svn\pristine\xx、obj\Debug\net8.0 这些子目录照样会被监视
                    for part in path:gmatch("[^/\\]+") do
                        if skip_watch[part] then return true end
                    end
                    return false
                end,
            },
            reload_on_bufenter = true,
        })
    end,
}
