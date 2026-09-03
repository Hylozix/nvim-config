-- 模糊查找：找文件、全文搜索、切缓冲区……一天用几百次
-- 依赖命令行工具 ripgrep(rg) 做全文搜索：scoop install ripgrep
-- fzf-native：C 实现的排序/匹配，输入过滤比默认 Lua sorter 跟手
-- live-grep-args：在搜索框里直接写 rg 参数，例如 "foo" -g*.js / "foo" -tjs
return {
    "nvim-telescope/telescope.nvim",
    -- 用 master 活跃分支：旧的 0.1.x 分支停更了，其预览器还在调用
    -- nvim-treesitter master 才有的 ft_to_lang()，和 main 分支一起用会报错
    branch = "master",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            -- Windows：MinGW Makefiles；Linux/macOS：make
            build = (vim.fn.has("win32") == 1)
                and
                'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -G "MinGW Makefiles" && cmake --build build --config Release && cmake --install build --prefix build'
                or "make",
        },
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            version = "^1.0.0",
        },
    },
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
        {
            "<leader>fg",
            function()
                require("telescope").extensions.live_grep_args.live_grep_args()
            end,
            desc = "全文搜索（可带 rg 参数）",
        },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "已打开的缓冲区" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "帮助文档" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近打开的文件" },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local lga_actions = require("telescope-live-grep-args.actions")

        telescope.setup({
            defaults = {
                prompt_prefix = "  ",
                selection_caret = "▌ ",
                path_display = { "filename_first" },
                layout_config = { horizontal = { preview_width = 0.55 } },
                -- Esc 一次直接关闭（默认要按两次）
                mappings = { i = { ["<esc>"] = actions.close } },
            },
            extensions = {
                live_grep_args = {
                    auto_quoting = true,
                    mappings = {
                        i = {
                            -- 把当前输入加引号，方便后面接 rg 参数
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            -- 加引号并接上 --iglob（按文件路径过滤）
                            -- 不用 <C-i>：它和 <Tab> 是同一个键码，会顶掉
                            -- telescope 默认的 <Tab>（多选 toggle_selection）
                            ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            -- 冻结当前结果，再在结果里二次模糊过滤
                            -- 注意：必须用 telescope.actions，lga_actions 里没有这个函数
                            -- 不用 <C-Space>：Windows/中文输入法常会截走
                            ["<C-f>"] = actions.to_fuzzy_refine,
                        },
                    },
                },
            },
        })
        -- 编译失败时不报错卡死，只是继续用默认 sorter
        pcall(telescope.load_extension, "fzf")
        telescope.load_extension("live_grep_args")
    end,
}
