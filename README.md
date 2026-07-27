# Neovim 配置

个人 Neovim 配置，基于 [lazy.nvim](https://github.com/folke/lazy.nvim) 管理插件。默认使用 **Neovide** + 中文 IME。

## 换电脑一键使用

```powershell
# Windows：配置目录是 %LOCALAPPDATA%\nvim
git clone <你的仓库地址> $env:LOCALAPPDATA\nvim
```

```bash
# macOS / Linux：配置目录是 ~/.config/nvim
git clone <你的仓库地址> ~/.config/nvim
```

然后打开 `nvim`：lazy.nvim 会自动 clone 自己、按 `lazy-lock.json` 装好所有插件；
首次启动还会自动做两件事——treesitter 编译语法解析器、mason 下载 LSP 服务器，
等右下角进度跑完重启一次即可。

### Windows / Linux 已适配的点

- **Shell**：Windows 用 `pwsh`，Linux/macOS 用 `bash`（见 `lua/config/options.lua`）
- **telescope-fzf-native**：Windows 用 MinGW cmake，Linux 用 `make`
- **编辑系统文件（无额外插件）**：mise 的 nvim 不在 root PATH，建议：
  - `sudo env "PATH=$PATH" nvim /etc/...`（推荐）
  - 或先在家目录编辑，再 `sudo cp` 到目标路径
  - 不要用 `:w !sudo tee %`（nvim 的 `!` 通常没有 TTY，sudo 要不到密码）

## 前置依赖

### 通用依赖（Windows / Linux 都要）

| 依赖 | 用途 | Windows（scoop / winget） | Linux（RHEL / Oracle Linux / Fedora） |
|------|------|---------------------------|---------------------------------------|
| **git** | lazy 拉取插件 | `winget install Git.Git` | `sudo dnf install -y git` |
| **Neovim** | 编辑器本体 | `scoop install neovim` | `mise use -g neovim@latest` 或系统包 |
| **C 编译器 + make** | treesitter / fzf-native 编译 | `scoop install mingw`（或 `zig`） | `sudo dnf install -y gcc gcc-c++ make` |
| **cmake** | Windows 上 fzf-native 编译 | `scoop install cmake` | 一般不需要（Linux 用 `make`）；可选 `sudo dnf install -y cmake` |
| **unzip** | 解压部分安装包 | 系统自带或 scoop | `sudo dnf install -y unzip` |
| **Node.js** | mason 装 LSP；`tree-sitter-cli` 依赖 npm | `scoop install nodejs-lts` | `mise use -g node@22` |
| **tree-sitter CLI** | nvim-treesitter 编译语法解析器 | `npm install -g tree-sitter-cli` | `npm install -g tree-sitter-cli` |
| **ripgrep** | telescope 全文搜索 | `scoop install ripgrep` | `mise use -g ripgrep` 或 `sudo dnf install -y ripgrep` |
| **fd**（可选） | telescope 找文件加速 | `scoop install fd` | `mise use -g fd` |
| **Nerd Font** | 图标显示（GUI / 本地终端） | [nerdfonts.com](https://www.nerdfonts.com/)，Neovide 默认 Maple Mono NF CN | SSH 用本地终端字体即可 |

> ⚠️ **不装 C 编译器**，treesitter / fzf-native 会编译失败。  
> ⚠️ **不装 `tree-sitter` CLI**，`:TSInstall` / `:TSUpdate` 会报 `ENOENT: 'tree-sitter'`。  
> ⚠️ Windows 上 fzf-native 需要 **cmake + mingw**；Linux 上配置已按系统自动用 `make`（见 `lua/plugins/telescope.lua`）。编译失败时 telescope 仍可用，只是搜索略慢。  
> ⚠️ **gcc / make / unzip** 属于系统工具链，Linux 上用 `dnf` 装；**node / neovim / ripgrep** 可用 [mise](https://mise.jdx.dev/) 按用户安装（类似 scoop，版本好切换）。

### Linux 推荐安装顺序（OCI / 服务器）

系统工具链（需要 sudo，装一次即可）：

```bash
sudo dnf install -y git gcc gcc-c++ make cmake unzip
```

用户级工具（以 `mise` 为例，装在当前用户家目录）：

```bash
# 安装 mise
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# 运行时与 CLI
mise use -g node@22 neovim@latest ripgrep fd

# treesitter 需要的 CLI（装完 node 后）
npm install -g tree-sitter-cli
which tree-sitter   # 应能找到命令
```

克隆本配置后打开 nvim：

```bash
git clone https://github.com/Hylozix/nvim-config.git ~/.config/nvim
nvim
# 首次等 lazy / treesitter / mason 跑完，再重启一次
# 若 fzf-native 编译失败：:Lazy build telescope-fzf-native.nvim
# 若 treesitter 缺 CLI：先装 tree-sitter-cli，再 :TSUpdate
```

### 同步配置时注意（`lazy-lock.json`）

在另一台机器上 `git pull` 若提示本地改动了 `lazy-lock.json` 会被覆盖，一般直接丢弃本地 lock 再拉即可：

```bash
cd ~/.config/nvim   # Windows: %LOCALAPPDATA%\nvim
git restore lazy-lock.json
git pull
```

### 按语言额外需要的工具链

只写对应语言时才装；mason 只给 LSP 本体，工具链要另装：

| 语言 | 工具链 | Windows 安装 |
|------|--------|--------------|
| Rust | rustup（rustc + cargo + rust-src） | `scoop install rustup` → `rustup default stable` → `rustup component add rust-src` |
| C# | .NET SDK + roslyn 服务器 | 见下方「C# 特别说明」 |
| C/C++、前端、Python 等 | 无（clangd/pyright 等开箱即用） | — |

### C# 特别说明

C# 不用 mason 的 omnisharp，改用微软官方新版 **roslyn**（由 `plugins/roslyn.lua` 驱动），
服务器作为**全局 dotnet 工具**安装：

```powershell
# 1. 装 .NET SDK（scoop 会自动设好 DOTNET_ROOT 环境变量）
scoop install dotnet-sdk
# 2. 装 roslyn 语言服务器（从微软 Azure 源，装到 ~\.dotnet\tools）
dotnet tool install -g roslyn-language-server --prerelease `
  --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
```

> roslyn 需要 **.NET 10 运行时**。它启动时靠环境变量 `DOTNET_ROOT` 找 dotnet；
> scoop 装 dotnet-sdk 时会自动把 `DOTNET_ROOT` 指向 scoop 的 dotnet，所以**新开终端**即可生效。
> 若打开 `.cs` 后 roslyn 没挂上，先确认是在**新终端**里启动的 nvim（老会话没有 `DOTNET_ROOT`）。

C# 格式化推荐全局安装 **csharpier**：`dotnet tool install -g csharpier`，并在 `conform.lua` 里启用 `cs = { "csharpier" }`。

## 目录结构

```
init.lua                      -- 入口：加载 config/，初始化 lazy
lua/
├── config/
│   ├── options.lua           -- 编辑器基础选项
│   ├── keymaps.lua           -- 全局按键映射
│   ├── autocmds.lua          -- 自动命令
│   ├── neovide.lua           -- Neovide GUI（字体、IME、标题栏、缩放）
│   └── colorscheme.lua       -- 主题应用与切换（不是 lazy 插件）
└── plugins/                  -- lazy 自动扫描，每个文件一个/一组插件
    ├── kanagawa.lua          -- 安装 kanagawa（并触发 colorscheme 配置）
    ├── tokyonight.lua        -- 安装 tokyonight（仅下载，由 kanagawa 依赖加载）
    ├── tree.lua              -- nvim-tree 文件树
    ├── treesitter.lua        -- 语法高亮
    ├── lsp.lua               -- LSP（mason + lspconfig + inlay hints）
    ├── roslyn.lua            -- C# roslyn 语言服务器
    ├── completion.lua        -- blink.cmp 自动补全
    ├── telescope.lua         -- 模糊查找（含 fzf-native 加速）
    ├── lualine.lua           -- 状态栏（含 navic 面包屑）
    ├── navic.lua             -- 代码结构面包屑
    ├── barbar.lua            -- 顶部标签栏
    ├── mini.lua              -- mini.surround / mini.indentscope
    ├── flash.lua             -- 屏内闪跳
    ├── fidget.lua            -- LSP 进度提示
    ├── gitsigns.lua          -- Git 标记
    ├── signify.lua           -- SVN 标记
    ├── which-key.lua         -- 按键提示
    ├── autopairs.lua         -- 自动配对括号
    ├── conform.lua           -- 保存时格式化
    ├── auto-session.lua      -- 会话保存/恢复
    ├── markdown-preview.lua  -- Markdown 预览
    └── neovime.lua           -- IME 相关
```

### 主题说明

- **安装**：`plugins/kanagawa.lua`、`plugins/tokyonight.lua`（lazy 从 GitHub 下载）
- **应用**：`config/colorscheme.lua`（默认 `kanagawa-wave`，不会去 git clone）
- 换默认主题：改 `config/colorscheme.lua` 里 `apply_theme("kanagawa-wave")`

## 常用快捷键（leader = 空格）

| 键 | 功能 |
|----|------|
| `<leader>e` / `<leader>ef` | 开关文件树 / 定位当前文件 |
| `<leader>ff` / `<leader>fg` | 查找文件 / 全文搜索 |
| `<leader>fb` / `<leader>fr` | 缓冲区 / 最近文件 |
| `<leader>tt` | Telescope 挑选主题 |
| `Ctrl+↑` / `Ctrl+↓` | 上一个 / 下一个主题 |
| `s` / `S` | Flash 跳转 / Flash 语法块 |
| `ys` / `ds` / `cs` | surround 加 / 删 / 改包围 |
| 选区 + `S` + 字符 | surround 给选区加括号/引号 |
| `gd` / `gr` / `gi` | 跳转定义 / 引用 / 实现 |
| `<leader>k` | 悬浮文档 |
| `<leader>rn` / `<leader>ca` | 重命名 / 代码操作 |
| `<leader>ci` | 开关 Inlay Hints |
| `<leader>d` / `[d` / `]d` | 查看诊断 / 上一条 / 下一条 |
| `[c` / `]c` | 上/下一处 Git 改动 |
| `<leader>hs` / `<leader>hp` | 暂存 / 预览 Git hunk |
| `[b` / `]b` / `<leader>bd` | 上/下一个 / 关闭 缓冲区 |
| `<leader>wr` / `<leader>ws` | 会话搜索 / 保存 |
| `gcc` / `gc`(选区) | 注释（nvim 内置） |
| `jj` | 插入模式退出到 Normal |
| `gp` / `gP` | 粘贴 0 号寄存器（不被删除覆盖） |

Neovide 专属：`Ctrl+=` / `Ctrl+-` / `Ctrl+0` 缩放，`F11` 全屏。

## 复现性

`lazy-lock.json` 锁定了每个插件的精确 commit。想升级用 `:Lazy update`（会更新 lock 文件）。

格式化器（stylua/prettier/black/csharpier 等）进 `:Mason` 面板或 `dotnet tool` 按需安装，
装好后到 `lua/plugins/conform.lua` 里取消对应行的注释。
