return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        -- 这些目录不自动建/恢复会话（避免在家目录乱存）
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        bypass_save_filetypes = { "NvimTree", "nvdash", "lazy", "mason", "qf" },
        session_lens = {
            -- 默认 true 会在启动时注册 telescope 扩展，把整个 telescope
            -- 拖进启动流程（约 23ms），telescope 的 cmd 懒加载就白设了。
            -- 关掉之后 <leader>wr 第一次用时才按需解析 picker，功能不变。
            load_on_setup = false,
            picker = "telescope",
        },
    },
    keys = {
        { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
        { "<leader>ws", "<cmd>AutoSession save<CR>",   desc = "Save session" },
        { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
    },
}
