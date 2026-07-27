-- 无权限文件保存：mise 装的 nvim 不在 root PATH，:w !sudo tee % 又常无 TTY 要密码
-- 用 :SudaWrite / <leader>W 可正确弹出密码并写入
return {
  "lambdalisue/suda.nvim",
  cmd = { "SudaRead", "SudaWrite" },
  keys = {
    { "<leader>W", "<cmd>SudaWrite<cr>", desc = "用 sudo 保存当前文件" },
  },
  config = function()
    -- 让 suda 用当前用户 PATH 里的工具（一般不需要改）
    vim.g.suda_smart_edit = 1
  end,
}
