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
      local signature_file = cache .. "config_signature"
      local chadrc_path = vim.fn.stdpath("config") .. "/lua/chadrc.lua"
      local chadrc = vim.fn.filereadable(chadrc_path) == 1 and vim.fn.readfile(chadrc_path) or {}
      local signature = vim.fn.sha256(table.concat(chadrc, "\n"))
      local saved_signature = vim.fn.filereadable(signature_file) == 1
          and vim.fn.readfile(signature_file)[1]
        or nil

      local function load_cached_highlights()
        -- 动态读取缓存目录，兼容 Base46 后续新增的 integration 文件。
        for _, name in ipairs(vim.fn.readdir(cache)) do
          if name ~= "config_signature" then
            local ok = pcall(dofile, cache .. name)
            if not ok then
              return false
            end
          end
        end
        return true
      end

      local cache_ready = vim.fn.filereadable(cache .. "defaults") == 1
      if not cache_ready or saved_signature ~= signature or not load_cached_highlights() then
        require("base46").load_all_highlights()
        vim.fn.mkdir(cache, "p")
        vim.fn.writefile({ signature }, signature_file)
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
