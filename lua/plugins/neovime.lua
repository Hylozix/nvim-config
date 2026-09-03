return {
    "sevenc-nanashi/neov-ime.nvim",
    lazy = false, -- IME 要尽早加载
    -- 只在 Neovide 里有用：负责预编辑（拼音候选）绘制，和 neovide.lua 里开关 IME 不重复
    cond = function()
        return vim.g.neovide
    end,
}
