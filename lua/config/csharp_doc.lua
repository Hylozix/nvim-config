-- C# XML 文档注释：调用 Roslyn 自带的 textDocument/_vs_onAutoInsert（VS / VS Code 敲 /// 用的就是它）
-- 参数名、泛型参数、是否 void 都由编译器判断，比 neogen 靠语法树猜的准。
--   插入模式在成员上方敲 ///  → 自动展开 <summary>/<param>/<typeparam>/<returns>
--   普通模式 <leader>ng       → 给光标所在的成员（方法/类/属性……）补一份
local M = {}

-- <leader>ng 时从光标处往上找到的第一个可写文档注释的节点
local members = {
  class_declaration = true,
  struct_declaration = true,
  interface_declaration = true,
  record_declaration = true,
  enum_declaration = true,
  enum_member_declaration = true,
  delegate_declaration = true,
  method_declaration = true,
  constructor_declaration = true,
  destructor_declaration = true,
  operator_declaration = true,
  conversion_operator_declaration = true,
  property_declaration = true,
  indexer_declaration = true,
  field_declaration = true,
  event_declaration = true,
  event_field_declaration = true,
}

local function get_client(buf)
  return vim.lsp.get_clients({ bufnr = buf, name = "roslyn" })[1]
end

-- 光标紧跟在 "///" 后面时向 Roslyn 要注释模板，以片段形式展开
-- on_empty：服务器不给模板时调用（比如成员已经有注释）
local function request(client, buf, position, on_empty)
  local tick = vim.b[buf].changedtick
  client:request("textDocument/_vs_onAutoInsert", {
    _vs_textDocument = { uri = vim.uri_from_bufnr(buf) },
    _vs_position = position,
    _vs_ch = "/",
    _vs_options = { tabSize = vim.fn.shiftwidth(), insertSpaces = vim.bo[buf].expandtab },
  }, function(err, result)
    if err or not (result and result._vs_textEdit) then
      if on_empty then on_empty() end
      return
    end
    -- 等回复期间又敲了字、换了缓冲区或退出了插入模式，就不再插入
    if vim.b[buf].changedtick ~= tick or vim.api.nvim_get_current_buf() ~= buf or vim.fn.mode() ~= "i" then
      return
    end

    local edit = result._vs_textEdit
    -- Roslyn 在 Windows 上用 \r\n 换行，且第 2 行起自带缩进；
    -- vim.snippet.expand 会再给这些行补一次当前行缩进，所以先把缩进去掉
    local lines = vim.split(edit.newText:gsub("\r\n", "\n"), "\n", { plain = true })
    for i = 2, #lines do
      lines[i] = lines[i]:gsub("^%s*", "")
    end
    local text = table.concat(lines, "\n")
    -- 1 = 纯文本，2 = 片段（目前 /// 都返回片段，纯文本时转义掉片段语法字符）
    if result._vs_textEditFormat ~= 2 then
      text = text:gsub("[%$}\\]", "\\%0")
    end

    local start = edit.range.start
    if start.line ~= edit.range["end"].line or start.character ~= edit.range["end"].character then
      vim.lsp.util.apply_text_edits({ { range = edit.range, newText = "" } }, buf, client.offset_encoding)
    end
    local line = vim.api.nvim_buf_get_lines(buf, start.line, start.line + 1, false)[1]
    local col = vim.str_byteindex(line, client.offset_encoding, start.character, false)
    vim.api.nvim_win_set_cursor(0, { start.line + 1, col })
    vim.snippet.expand(text)
  end, buf)
end

-- <leader>ng：在光标所在成员上方插一行 "///"，再走同一个请求
function M.generate()
  local buf = vim.api.nvim_get_current_buf()
  local client = get_client(buf)
  if not client then
    return vim.notify("Roslyn 还没连上，稍后再试", vim.log.levels.WARN)
  end
  local node = vim.treesitter.get_node({ bufnr = buf })
  while node and not members[node:type()] do
    node = node:parent()
  end
  if not node then
    return vim.notify("光标不在可写文档注释的成员上", vim.log.levels.WARN)
  end

  -- 成员节点的起始行已包含 [Attribute]，注释插在特性之上，和 VS 一致
  local row = node:start()
  local indent = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]:match("^%s*")
  vim.api.nvim_buf_set_lines(buf, row, row, false, { indent .. "///" })
  vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 2 })
  vim.cmd("startinsert!")
  -- 缩进只含空白，字节数就是 UTF-16 列号
  request(client, buf, { line = row, character = #indent + 3 }, function()
    -- 服务器不给模板（成员已有注释等）就撤掉刚插的那行
    vim.cmd("stopinsert")
    if vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] == indent .. "///" then
      vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
    end
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("csharp_doc", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- Razor 文件里的 C# 位置要经过映射，只处理纯 .cs
      if not client or client.name ~= "roslyn" or vim.bo[args.buf].filetype ~= "cs" then return end
      local buf = args.buf
      vim.api.nvim_clear_autocmds({ group = group, buffer = buf })

      vim.api.nvim_create_autocmd("InsertCharPre", {
        group = group,
        buffer = buf,
        callback = function()
          if vim.v.char ~= "/" then return end
          -- InsertCharPre 时字符还没进缓冲区，下一轮事件循环再看
          vim.schedule(function()
            if vim.api.nvim_get_current_buf() ~= buf then return end
            local col = vim.api.nvim_win_get_cursor(0)[2]
            -- 光标前正好是「缩进 + ///」才请求，免得每个 / 都打扰服务器
            if not vim.api.nvim_get_current_line():sub(1, col):match("^%s*///$") then return end
            local c = get_client(buf)
            if c then
              request(c, buf, vim.lsp.util.make_position_params(0, c.offset_encoding).position)
            end
          end)
        end,
      })

      -- 缓冲区映射优先于 neogen 的全局 <leader>ng，C# 改走 Roslyn
      vim.keymap.set("n", "<leader>ng", M.generate, { buffer = buf, desc = "Generate documentation (Roslyn)" })
    end,
  })
end

return M
