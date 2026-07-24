-- mini.nvim：按需启用子模块（比各自独立插件更轻）
-- surround：括号/引号操作；indentscope：当前缩进块参考线
return {
  "nvim-mini/mini.nvim",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- 键位对齐 vim-surround 肌肉记忆：ys 加、ds 删、cs 改
    require("mini.surround").setup({
      mappings = {
        add = "ys",
        delete = "ds",
        replace = "cs",
        find = "",
        find_left = "",
        highlight = "",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
    })

    -- 只高亮「当前所在」缩进层级（不是每一级都画线；比 indent-blankline 更轻）
    require("mini.indentscope").setup({
      symbol = "│",
      options = { try_as_border = true },
    })
  end,
}
