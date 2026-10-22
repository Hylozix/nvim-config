-- NvChad Tabufline 性能补丁：不改插件源码，替换 nvchad.tabufline.utils 里的两个局部函数。
-- 原实现每画一个标签都把它和所有缓冲区比一遍文件名（n² 次），而取文件名的
-- 正则 "([^/\\]+)[/\\]*$" 在长路径上又很慢（单次 18~40µs），
-- 155 个缓冲区时每次重绘约 100ms，打字每个键都卡。
-- 这里改成每次重绘只统计一遍文件名出现次数，取文件名也改成线性匹配。
local M = {}

-- 和原 filename() 行为一致：去掉末尾分隔符后取最后一段，空串返回 nil
local function filename(str)
  str = str:gsub("[/\\]+$", "")
  if str == "" then
    return nil
  end
  return str:match("^.*[/\\](.+)$") or str
end

-- 本次重绘里每个文件名出现的次数。modules.buffers 每次重绘都从 index 1 开始调用 style_buf，
-- 所以在 index == 1 时重新统计即可
local name_counts

local function gen_unique_name(name, index)
  local bufs = vim.t.bufs
  if index == 1 or not name_counts then
    name_counts = {}
    for _, nr in ipairs(bufs) do
      local n = filename(vim.api.nvim_buf_get_name(nr))
      if n then
        name_counts[n] = (name_counts[n] or 0) + 1
      end
    end
  end
  if (name_counts[name] or 0) > 1 then
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufs[index]), ":h:t") .. "/" .. name
  end
end

function M.setup()
  local ok, utils = pcall(require, "nvchad.tabufline.utils")
  if not ok or type(utils.style_buf) ~= "function" then
    return
  end
  -- 两个函数是 utils.lua 的局部变量，以 upvalue 形式被 style_buf 引用；
  -- 替换 upvalue 后 modules.lua 里缓存的 style_buf 引用也会生效。
  -- NvChad 以后改名或重构时找不到对应 upvalue，就保持原样不打补丁。
  local patched = {}
  for i = 1, math.huge do
    local up = debug.getupvalue(utils.style_buf, i)
    if up == nil then
      break
    end
    if up == "filename" then
      debug.setupvalue(utils.style_buf, i, filename)
      patched.filename = true
    elseif up == "gen_unique_name" then
      debug.setupvalue(utils.style_buf, i, gen_unique_name)
      patched.gen_unique_name = true
    end
  end
  if not (patched.filename and patched.gen_unique_name) then
    vim.notify("tabufline 性能补丁未生效：NvChad 内部函数已变化", vim.log.levels.WARN)
  end
end

return M
