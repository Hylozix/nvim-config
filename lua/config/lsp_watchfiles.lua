-- 修 nvim 0.12 在 Windows 上 LSP 文件监听（workspace/didChangeWatchedFiles）完全不生效的 bug。
-- nvim 注册监听时用 vim.uri_to_fname() 拼匹配模式，得到 c:\Users\...\proj/**/*.cs；
-- 监听回调给出的却是 vim.fs.normalize 过的路径 C:/Users/.../proj/x.cs，两者永远对不上，
-- 于是新建/删除 .cs、改 .csproj 等事件一个都发不到语言服务器（Roslyn 只能把新文件当杂项文件）。
-- 这里包一层 _watchfunc（nvim 留给测试替换的钩子），把回调路径换回注册时的写法再交给原逻辑匹配。
-- 返回 { ok = 是否可用 }：ok 为 false 时调用方应退回服务器自带的监听。
local M = { ok = false }

if vim.fn.has("win32") == 0 then
  M.ok = true -- 其它系统没有这个问题
  return M
end

local ok, watchfiles = pcall(require, "vim.lsp._watchfiles")
if not ok or type(watchfiles._watchfunc) ~= "function" then
  return M -- 内部实现变了，不冒险打补丁
end

local orig = watchfiles._watchfunc
watchfiles._watchfunc = function(base_dir, opts, callback)
  local norm_base = vim.fs.normalize(base_dir)
  -- 两种写法一致（比如以后 nvim 修了），原样交回
  if norm_base == base_dir then
    return orig(base_dir, opts, callback)
  end
  local include = opts.include_pattern
  -- include_pattern 也是按注册时的写法拼的，原函数里会把所有事件都过滤掉，挪到下面换完路径再匹配
  return orig(base_dir, { uvflags = opts.uvflags, exclude_pattern = opts.exclude_pattern }, function(path, change_type)
    if path:sub(1, #norm_base) == norm_base then
      path = base_dir .. path:sub(#norm_base + 1)
    end
    if include and include:match(path) == nil then return end
    callback(path, change_type)
  end)
end

M.ok = true
return M
