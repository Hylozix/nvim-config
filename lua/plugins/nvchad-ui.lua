-- NvChad 的 UI 层：只接管状态栏、Tabufline、主题和 Nvdash。
-- LSP、补全、格式化、文件树等仍由本配置的原有插件负责。
return {
  "nvim-lua/plenary.nvim",
  {
    "nvchad/base46",
    branch = "v3.0",
    lazy = false,
    build = function()
      require("base46").load_all_highlights()
    end,
  },
  {
    "nvchad/ui",
    branch = "v3.0",
    lazy = false,
    dependencies = {
      "nvchad/base46",
      "nvzone/volt",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local cache = vim.g.base46_cache
      local fs_stat = (vim.uv or vim.loop).fs_stat

      -- 首次安装时 build 可能尚未生成缓存，启动时补生成一次。
      if not fs_stat(cache .. "defaults") then
        require("base46").load_all_highlights()
      end

      require("nvchad")
      require("config.colorscheme").setup()
    end,
  },
  { "nvzone/volt", lazy = true },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = function()
      local ok, icons = pcall(require, "nvchad.icons.devicons")
      return ok and { override = icons } or {}
    end,
  },
}
