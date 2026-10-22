-- 把创建自动命令的函数赋值给局部变量，简化写法
local autocmd = vim.api.nvim_create_autocmd

-- 超过 1 MiB 的文件和压缩 JS/CSS 关闭高开销的显示功能。
autocmd({ "BufReadPre", "BufNewFile" }, {
  callback = function(ev)
    local stat = vim.uv.fs_stat(ev.file)
    local large = (stat ~= nil and stat.size > 1024 * 1024)
      or ev.file:match("%.min%.js$") ~= nil
      or ev.file:match("%.min%.css$") ~= nil
    vim.b[ev.buf].large_file = large
    if large then
      vim.b[ev.buf].miniindentscope_disable = true
    end
  end,
})

autocmd("BufWinEnter", {
  callback = function(ev)
    if vim.b[ev.buf].large_file then
      vim.opt_local.foldmethod = "manual"
      vim.bo[ev.buf].syntax = ""
    end
  end,
})

-- 缓冲区自动清理：最多保留最近用过的 20 个。
-- NvChad 标签栏每次重绘都会把每个缓冲区和其它所有缓冲区比一遍名字（O(n²)），
-- auto-session 一路攒到 155 个时重绘一次要 100ms，打字每个键都卡。
-- 有未保存修改、正在窗口里显示的缓冲区不动；用 :bdelete 只是移出列表，标记和撤销历史都还在。
local max_buffers = 20
local buf_seq = 0
local pruning = false
autocmd("BufEnter", {
  callback = function(ev)
    buf_seq = buf_seq + 1
    vim.b[ev.buf].last_used_seq = buf_seq
    if pruning then return end
    pruning = true
    -- 等 BufEnter 这一轮处理完再删，避免在其它插件的回调过程中改动缓冲区
    vim.schedule(function()
      local bufs = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted and vim.bo[b].buftype == ""
      end, vim.api.nvim_list_bufs())
      if #bufs > max_buffers then
        -- 从没进入过的（会话恢复出来的）排最前，其次按最近使用的先后
        table.sort(bufs, function(a, b)
          local sa, sb = vim.b[a].last_used_seq or 0, vim.b[b].last_used_seq or 0
          if sa ~= sb then return sa < sb end
          return vim.fn.getbufinfo(a)[1].lastused < vim.fn.getbufinfo(b)[1].lastused
        end)
        local excess = #bufs - max_buffers
        for _, b in ipairs(bufs) do
          if excess == 0 then break end
          if not vim.bo[b].modified and #vim.fn.win_findbuf(b) == 0 then
            pcall(vim.cmd.bdelete, b)
            excess = excess - 1
          end
        end
      end
      pruning = false
    end)
  end,
})

-- Razor 页面同时包含 HTML 和 C#，统一交给 roslyn.nvim 的 razor 客户端处理。
-- 显式覆盖 .cshtml，避免它被默认识别成普通 html 而跳过 Roslyn。
vim.filetype.add({
  extension = {
    razor = "razor",
    cshtml = "razor",
  },
})

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
