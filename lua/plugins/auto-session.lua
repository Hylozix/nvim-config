return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        -- 这些目录不自动建/恢复会话（避免在家目录乱存）
        suppressed_dirs = { "~/", "~/Downloads", "/" },
    },
    keys = {
        { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
        { "<leader>ws", "<cmd>AutoSession save<CR>",   desc = "Save session" },
        { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
    },
}
