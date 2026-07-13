-- 把创建自动命令的函数赋值给局部变量，简化写法
local autocmd = vim.api.nvim_create_autocmd

-- 自动命令：复制（yank）后短暂高亮被复制的文本，方便确认复制范围
autocmd("TextYankPost", { -- 触发事件：任何 yank/删除进寄存器之后
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 }) -- 高亮持续 200 毫秒
  end,
})

-- 自动命令：打开文件后，自动跳转到上次关闭时光标所在的位置
autocmd("BufReadPost", {  -- 触发事件：文件读取完成后（打开文件时触发）
  pattern = "*",          -- 生效范围：对所有类型的文件都生效
  callback = function()   -- 触发事件后执行的回调函数
    -- 从 Neovim 的标记中，读取上次关闭文件时光标所在的行号
    local line = vim.fn.line("'\"")
    -- 判断行号是否合法：大于第1行，且不超过文件的总行数
    if line > 1 and line <= vim.fn.line("$") then
      -- 执行普通模式命令，跳转到上次光标所在的位置
      vim.cmd.normal('g`"')
    end
  end,
})
