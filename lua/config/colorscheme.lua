-- 主题应用与切换（纯配置，不是 lazy 插件，不会去 git clone）
local M = {}

function M.setup()
  local themes = {
    "kanagawa-wave",
    "kanagawa-dragon",
    "kanagawa-lotus",
    "kanagawa",
    "tokyonight-storm",
    "tokyonight-night",
    "tokyonight-day",
    "tokyonight-moon",
  }

  local function apply_theme(name)
    return pcall(vim.cmd.colorscheme, name)
  end

  local function cycle_theme(delta)
    local current = vim.g.colors_name
    local start = 1
    for i, name in ipairs(themes) do
      if name == current then
        start = i
        break
      end
    end
    for n = 1, #themes do
      local idx = ((start + delta * n - 1) % #themes) + 1
      if apply_theme(themes[idx]) then
        vim.notify(themes[idx], vim.log.levels.INFO, { title = "主题" })
        return
      end
    end
  end

  apply_theme("kanagawa-wave")

  vim.keymap.set("n", "<C-Up>", function() cycle_theme(-1) end, { desc = "上一个主题" })
  vim.keymap.set("n", "<C-Down>", function() cycle_theme(1) end, { desc = "下一个主题" })
  vim.keymap.set("n", "<leader>tt", "<cmd>Telescope colorscheme<cr>", { desc = "挑选主题" })
end

return M
