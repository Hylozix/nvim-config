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
  ft = "cs", -- 只在打开 C# 文件时加载
  opts = {},
}
