-- 状态栏：底部显示模式、分支、文件名、面包屑、诊断、位置等
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "SmiteshP/nvim-navic", -- 提供 lualine_c 里的 navic 组件
  },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto", -- 跟随当前 colorscheme（换 kanagawa/tokyonight 都不用再改）
      globalstatus = true,  -- 整个窗口共用一条状态栏，而不是每个分屏一条
      section_separators = "",
      component_separators = "|",
    },
    sections = {
      lualine_c = {
        "filename",
        {
          "navic",
          color_correction = "dynamic",
          navic_opts = nil,
        },
      },
    },
  },
}
