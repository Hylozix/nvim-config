-- NvChad UI 的本地配置。这里只描述 UI，不替换本配置的开发工具链。
---@type ChadrcConfig
local M = {}

M.base46 = {
  -- 保留原配置偏好的 Kanagawa 配色，UI 布局仍由 NvChad 提供。
  theme = "palenight",
  theme_toggle = { "palenight", "kanagawa-dragon" },
  transparency = false,
}

M.ui = {
  statusline = {
    enabled = true,
    -- 平直色块布局最接近参考图中的 NvChad 状态栏。
    theme = "vscode_colored",
    separator_style = "default",
  },
  tabufline = {
    enabled = true,
    lazyload = false,
    treeOffsetFt = "NvimTree",
    bufwidth = 21,
  },
  telescope = { style = "borderless" },
  cmp = { style = "default" },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "                      ",
    "  ▄▄         ▄ ▄▄▄▄▄▄▄",
    "▄▀███▄     ▄██ █████▀ ",
    "██▄▀███▄   ███        ",
    "███  ▀███▄ ███        ",
    "███    ▀██ ███        ",
    "███      ▀ ███        ",
    "▀██ █████▄▀█▀▄██████▄ ",
    "  ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀",
    "                      ",
    "  Powered By  eovim ",
    "                      ",
  },
  buttons = {
    { txt = "  查找文件", keys = "ff", cmd = "Telescope find_files" },
    { txt = "  最近文件", keys = "fr", cmd = "Telescope oldfiles" },
    { txt = "󰈭  全文搜索", keys = "fg", cmd = "Telescope live_grep" },
    { txt = "󱥚  主题", keys = "tt", cmd = ":lua require('nvchad.themes').open()" },
    { txt = "  快捷键", keys = "ch", cmd = "NvCheatsheet" },
  },
}

M.cheatsheet = { theme = "grid" }

-- NvChad 这里只负责 UI，不额外介入现有 LSP 或代码颜色行为。
M.lsp = { signature = false }
M.colorify = { enabled = false }

return M
