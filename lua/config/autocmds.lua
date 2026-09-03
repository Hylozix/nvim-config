-- 把创建自动命令的函数赋值给局部变量，简化写法
local autocmd = vim.api.nvim_create_autocmd

-- 自动命令：复制（yank）后短暂高亮被复制的文本，方便确认复制范围
autocmd("TextYankPost", { -- 触发事件：任何 yank/删除进寄存器之后
  pattern = "*",
  callback = function()
    -- vim.highlight 在 0.11 起已弃用（0.13 移除），改用 vim.hl
    vim.hl.on_yank({ timeout = 200 }) -- 高亮持续 200 毫秒
  end,
})

-- 自动命令：打开文件后，自动跳转到上次关闭时光标所在的位置
autocmd("BufReadPost", {
  callback = function(ev)
    local buf = ev.buf
    -- 终端 / quickfix 等特殊缓冲区、git 提交信息不要跳
    if vim.bo[buf].buftype ~= "" then
      return
    end
    if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local line_count = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
