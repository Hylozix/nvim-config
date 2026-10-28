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

local Deleted = require("vim._watch").FileChangeType.Deleted

local orig = watchfiles._watchfunc
watchfiles._watchfunc = function(base_dir, opts, callback)
  local norm_base = vim.fs.normalize(base_dir)
  local include = opts.include_pattern
  local cancel, stopped
  -- 原 cancel 第二次调用会对已关闭的句柄 stop 报错，这里只放行一次
  local function stop()
    if stopped then return end
    stopped = true
    cancel()
  end
  -- include_pattern 也是按注册时的写法拼的，原函数里会把所有事件都过滤掉，挪到下面换完路径再匹配
  cancel = orig(base_dir, { uvflags = opts.uvflags, exclude_pattern = opts.exclude_pattern }, function(path, change_type)
    if stopped then return end
    -- 被监听的目录本身被删了（比如 Roslyn 清理 Temp\MetadataAsSource 下的反编译目录），
    -- Windows 上 libuv 会反复报同一个 rename 事件并立刻重新挂监听，每秒几万次回调占满主循环，
    -- 搜索、yank 高亮这些全都卡住。目录都没了，监听也没用，直接停掉。
    if change_type == Deleted and not vim.uv.fs_stat(norm_base) then
      stop()
      return
    end
    if path:sub(1, #norm_base) == norm_base then
      path = base_dir .. path:sub(#norm_base + 1)
    end
    if include and include:match(path) == nil then return end
    callback(path, change_type)
  end)
  return stop
end

M.ok = true
return M
