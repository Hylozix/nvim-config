-- 状态栏：底部显示模式、分支、文件名、诊断、位置等
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "SmiteshP/nvim-navic", -- 提供 winbar 里的 navic 面包屑组件
  },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto", -- 跟随当前 colorscheme（换 kanagawa/tokyonight 都不用再改）
      globalstatus = true, -- 整个窗口共用一条状态栏，而不是每个分屏一条
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
      disabled_filetypes = { winbar = { "NvimTree", "lazy", "mason", "qf", "help" } },
    },
    sections = {
      lualine_c = {
        { "filename", path = 1 }, -- 相对路径，避免只显示 basename 分不清同名文件
      },
    },
    -- 面包屑放到窗口顶栏，状态栏不再和文件名挤在一起
    winbar = {
      lualine_c = {
        { "navic", color_correction = "dynamic", navic_opts = nil },
      },
    },
    inactive_winbar = {
      lualine_c = { { "filename", path = 1 } },
    },
  },
}
