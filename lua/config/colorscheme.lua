-- NvChad Base46 主题切换。快捷键保持原配置不变。
local M = {}

function M.setup()
  local themes = {
    "onedark",
    "one_light",
    "tokyonight",
    "catppuccin",
    "gruvbox",
    "nord",
    "rosepine",
    "everforest",
    "kanagawa",
    "vscode_dark",
  }

  local function apply_theme(name, notify)
    local ok = pcall(function()
      require("nvchad.themes.utils").reload_theme(name)
    end)
    if ok and notify then
      vim.notify(name, vim.log.levels.INFO, { title = "NvChad 主题" })
    end
    return ok
  end

  local function cycle_theme(delta)
    local current = require("nvconfig").base46.theme
    local start = 1
    for i, name in ipairs(themes) do
      if name == current then
        start = i
        break
      end
    end
    for n = 1, #themes do
      local idx = ((start + delta * n - 1) % #themes) + 1
      if apply_theme(themes[idx], true) then
        return
      end
    end
  end

  vim.keymap.set("n", "<C-Up>", function() cycle_theme(-1) end, { desc = "上一个主题" })
  vim.keymap.set("n", "<C-Down>", function() cycle_theme(1) end, { desc = "下一个主题" })
  vim.keymap.set("n", "<leader>tt", function()
    local ok, picker = pcall(require, "nvchad.themes")
    if ok then
      picker.open()
    else
      vim.notify("NvChad 主题选择器尚未加载", vim.log.levels.WARN)
    end
  end, { desc = "挑选 NvChad 主题" })
end

return M
