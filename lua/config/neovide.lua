-- Neovide（图形界面前端）专属配置
-- 在终端里跑 nvim 时 vim.g.neovide 不存在，直接返回，本文件等于不生效
if not vim.g.neovide then
  return
end

-------------字体-------------
-- 终端里字体归终端管，GUI 里才由 guifont 控制
-- Maple Mono NF CN：带 Nerd Font 图标 + 中文字形，中英文 2:1 等宽（中文注释不错位）
-- 逗号后是备用字体：前一个没装时依次往后找
vim.o.guifont = "Maple Mono NF CN,JetBrainsMono NF:h12"
vim.opt.linespace = 2 -- 行间距（像素），中文夹杂时稍微松一点更舒服

-------------缩放（Ctrl+= 放大 / Ctrl+- 缩小 / Ctrl+0 复原）-------------
vim.g.neovide_scale_factor = 1.0
local function zoom(delta)
  vim.g.neovide_scale_factor = math.max(0.5, math.min(2.0, vim.g.neovide_scale_factor + delta))
end
vim.keymap.set({ "n", "i", "v", "t" }, "<C-=>", function() zoom(0.1) end, { desc = "Neovide 放大" })
vim.keymap.set({ "n", "i", "v", "t" }, "<C-->", function() zoom(-0.1) end, { desc = "Neovide 缩小" })
vim.keymap.set({ "n", "i", "v", "t" }, "<C-0>", function() vim.g.neovide_scale_factor = 1.0 end, { desc = "Neovide 缩放复原" })

-------------窗口行为-------------
vim.g.neovide_remember_window_size = true -- 记住上次关闭时的窗口大小和位置
vim.g.neovide_confirm_quit = true         -- 有未保存的修改时，关窗口前弹确认，防手滑
vim.g.neovide_hide_mouse_when_typing = true -- 打字时自动隐藏鼠标指针
-- 内容与窗口边缘的留白（像素）
vim.g.neovide_padding_top = 4
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_left = 6
vim.g.neovide_padding_right = 6
-- F11 切换全屏
vim.keymap.set("n", "<F11>", function()
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "Neovide 全屏切换" })

-------------动画手感-------------
-- Neovide 默认动画偏"飘"，下面调短一些：保留丝滑感但不拖泥带水
vim.g.neovide_cursor_animation_length = 0.08 -- 光标移动动画时长（秒）
vim.g.neovide_cursor_trail_size = 0.5        -- 光标拖尾长度（0~1，0 关闭）
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_scroll_animation_length = 0.15 -- 滚动动画时长
vim.g.neovide_position_animation_length = 0.1 -- 分屏/窗口移动动画时长
-- 光标粒子特效，喜欢花哨可改成 "railgun"/"torpedo"/"pixiedust"，空串为关闭
vim.g.neovide_cursor_vfx_mode = ""

-------------性能-------------
vim.g.neovide_refresh_rate = 60      -- 活跃时的刷新率
vim.g.neovide_refresh_rate_idle = 5  -- 失焦/空闲时降到 5 帧，省电省 GPU

-------------中文输入法（重要）-------------
-- 只在插入模式和搜索时启用 IME；回到普通模式自动切回英文输入，
-- 这样 j/k 移动、各种快捷键不会被中文输入法拦截，不用手动切换
vim.g.neovide_input_ime = true
local ime_group = vim.api.nvim_create_augroup("neovide_ime", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  group = ime_group,
  callback = function(ev)
    vim.g.neovide_input_ime = (ev.event == "InsertEnter")
  end,
})
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
  group = ime_group,
  -- 只在 / ? 搜索时开 IME，: 命令行保持英文
  -- 注意必须用列表写法：Neovide 官方文档的 "[/\?]" 字符组写法在 nvim 0.12 上不生效
  pattern = { "/", "?" },
  callback = function(ev)
    vim.g.neovide_input_ime = (ev.event == "CmdlineEnter")
  end,
})

-------------剪贴板便捷键-------------
-- Ctrl+Shift+V：在插入/命令行/终端模式直接粘贴系统剪贴板
vim.keymap.set({ "i", "c" }, "<C-S-v>", "<C-r>+", { desc = "粘贴系统剪贴板" })
vim.keymap.set("t", "<C-S-v>", '<C-\\><C-n>"+pi', { desc = "终端内粘贴系统剪贴板" })

-- 可选项备忘（需要时取消注释）：
-- vim.g.neovide_opacity = 0.95          -- 窗口整体透明度（1.0 不透明）
-- vim.g.neovide_floating_blur_amount_x = 2.0 -- 浮动窗口毛玻璃模糊
-- vim.g.neovide_floating_blur_amount_y = 2.0
