-- 状态栏：底部显示模式、分支、文件名、诊断、位置等
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "tokyonight", -- 跟随主题
      globalstatus = true,  -- 整个窗口共用一条状态栏，而不是每个分屏一条
      section_separators = "",
      component_separators = "|",
    },
  },
}
