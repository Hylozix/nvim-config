-- 新建/删除 .cs 后让 Roslyn 重新加载所属项目。
-- Roslyn 会监听项目目录下的 **/*.cs，但收到「新建/删除」通知后并不重新加载项目（只认 .csproj 的改动），
-- 于是新建的文件一直被当成杂项文件：用不了同项目的类型、没有补全、也不报编译错误。
-- 这里在 nvim 发出的 workspace/didChangeWatchedFiles 里，顺带补一条所属 .csproj 的「已修改」，
-- 效果等同于改了一下 .csproj，但不动磁盘上的文件（不影响 SVN/Rider/增量编译）。
-- 依赖 nvim 的文件监听可用（config/lsp_watchfiles.lua）。
local M = {}

local Created, Changed, Deleted = 1, 2, 3

-- 向上找离文件最近的 .csproj（目录可能已被整个删掉，出错就当没找到，别连累正常通知）
local function owning_project(path)
  local ok, found = pcall(vim.fs.find, function(name)
    return name:match("%.csproj$") ~= nil
  end, { path = vim.fs.dirname(path), upward = true, type = "file", limit = 1 })
  return ok and found[1] or nil
end

local function is_source(path)
  return (path:match("%.cs$") or path:match("%.razor$") or path:match("%.cshtml$"))
    -- 编译时 obj/ 下会生成 .cs，不能因此反复重新加载
    and not path:match("[/\\]obj[/\\]")
    and not path:match("[/\\]bin[/\\]")
end

local function wrap(client)
  local notify = client.notify
  client.notify = function(self, method, params)
    if method == "workspace/didChangeWatchedFiles" and params and params.changes then
      local seen = {}
      local extra = {}
      for _, change in ipairs(params.changes) do
        if change.type == Created or change.type == Deleted then
          local path = vim.uri_to_fname(change.uri)
          local project = is_source(path) and owning_project(path)
          if project and not seen[project] then
            seen[project] = true
            table.insert(extra, { uri = vim.uri_from_fname(project), type = Changed })
          end
        end
      end
      vim.list_extend(params.changes, extra)
    end
    return notify(self, method, params)
  end
end

function M.setup()
  local wrapped = {}
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("roslyn_reload", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "roslyn" and not wrapped[client.id] then
        wrapped[client.id] = true
        wrap(client)
      end
    end,
  })
end

return M
