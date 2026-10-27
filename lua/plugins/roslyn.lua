-- C# 语言服务器：roslyn（微软官方新版，就是 VS Code C# Dev Kit 用的那个）
-- 这个插件只负责驱动服务器（找 .sln/.csproj、启动等）；服务器本体不走 mason，
-- 而是作为全局 dotnet 工具安装（见 README 的 C# 一节）：
--   dotnet tool install -g roslyn-language-server --prerelease --source <微软 Azure 源>
-- roslyn.nvim 会自动从 PATH（~\.dotnet\tools）找到 roslyn-language-server.cmd。
-- 补全能力已由 lsp.lua 的 vim.lsp.config("*") 通配设置，roslyn 自动继承。
-- 依赖：.NET SDK + nvim ≥ 0.12 + 环境变量 DOTNET_ROOT 指向含 .NET 10 运行时的 dotnet
--       （scoop 装 dotnet-sdk 会自动设好 DOTNET_ROOT）
return {
  "seblyng/roslyn.nvim",
  ft = { "cs", "razor" }, -- C# 和 Razor/CSHTML 都需要 Roslyn
  opts = {
    -- 让 Roslyn 自行监听项目文件变化，保存 .csproj 后更新项目引用。
    -- 插件在 config 里才设置它，赶不上第一个客户端；真正生效靠下面 init 里的 capabilities，
    -- 这里保留是为了 :checkhealth roslyn 显示正确。
    filewatching = "roslyn",
  },
  -- 客户端配置必须写在 init（启动时执行，早于插件加载），不能放 config：
  -- lazy 在 FileType 事件里加载本插件，plugin/roslyn.lua 一执行 vim.lsp.enable("roslyn")，
  -- nvim 见 did_filetype() 为真就当场启动客户端，config() 里的 vim.lsp.config 赶不上第一个客户端。
  init = function()
    vim.lsp.config("roslyn", {
      -- 即 filewatching = "roslyn" 的效果：不向服务器声明能替它监听文件，
      -- 让 Roslyn 用自己的 FileSystemWatcher，改 .csproj 后自动重新加载项目。
      -- （声明了的话会交给 nvim 的监听，Windows 上改 .csproj 服务器收不到）
      capabilities = {
        workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
      },
      handlers = {
        -- 项目重新加载后 Roslyn 会发这个通知。nvim 0.12 见服务器支持 workspace 诊断就只重拉
        -- workspace 诊断，而 Roslyn 的 workspace 诊断不含已打开的文件，于是打开着的 .cs
        -- 还挂着旧报错、要编辑一下才更新。这里给已打开的缓冲区补拉一次文档诊断。
        -- （据 roslyn.nvim 的注释，nvim 0.13 已修复并移除了 _refresh，届时这段自动跳过）
        ["workspace/diagnostic/refresh"] = function(err, result, ctx)
          local refresh = vim.lsp.diagnostic._refresh
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          if refresh and client then
            for bufnr in pairs(client.attached_buffers) do
              if vim.api.nvim_buf_is_loaded(bufnr) then
                refresh(bufnr, ctx.client_id)
              end
            end
          end
          return vim.lsp.handlers["workspace/diagnostic/refresh"](err, result, ctx)
        end,
        ["razor/updateHtml"] = function(_, params)
          local document = require("roslyn.razor.documentManager"):updateDocumentText(
            params.textDocument.uri, params.checksum, params.text
          )
          -- 虚拟缓冲区可能跳过文件类型检测，导致 HTML 补全转发每次同步等待 5 秒。
          if vim.bo[document.buf].filetype ~= "html" then
            vim.bo[document.buf].filetype = "html"
          end
          return false
        end,
      },
    })
  end,
  config = function(_, opts)
    require("roslyn").setup(opts)
    -- 敲 /// 或 <leader>ng 生成 XML 文档注释（用 Roslyn 自带的生成器，见 config/csharp_doc.lua）
    require("config.csharp_doc").setup()
  end,
}
