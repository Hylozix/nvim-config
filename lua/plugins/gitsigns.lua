-- Git 集成：左侧标记增删改、行内 diff、暂存单个 hunk
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(keys, fn, desc)
        vim.keymap.set("n", keys, fn, { buffer = bufnr, silent = true, desc = desc })
      end
      map("]c", function() gs.nav_hunk("next") end, "下一处改动")
      map("[c", function() gs.nav_hunk("prev") end, "上一处改动")
      map("<leader>hs", gs.stage_hunk, "暂存当前 hunk")
      map("<leader>hr", gs.reset_hunk, "撤销当前 hunk")
      map("<leader>hp", gs.preview_hunk, "预览当前 hunk")
      map("<leader>hb", function() gs.blame_line({ full = true }) end, "查看本行 blame")
    end,
  },
}
