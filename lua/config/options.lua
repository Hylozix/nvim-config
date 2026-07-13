local opt = vim.opt

--行号和光标
opt.number = true --显示绝对行号
opt.relativenumber = true --显示相对行号
opt.cursorline = true --高亮当前光标所在行


--缩进和制表符规则
opt.tabstop = 4 --一个tab字符设为4个空格宽度
opt.shiftwidth = 4 --自动缩进宽度为4个空格
opt.expandtab = true --按下tab键时，自动替换为空格
opt.autoindent = true     -- 换行时自动继承上一行的缩进
opt.smartindent = true    -- 智能缩进：针对代码语法自动调整


--搜索
opt.ignorecase = true     -- 搜索时默认忽略大小写
opt.smartcase = true      -- 智能大小写：如果搜索内容里包含大写字母，自动切换为区分大小写
opt.hlsearch = true       -- 搜索结果高亮：所有匹配项都高亮显示
opt.incsearch = true      -- 增量搜索：输入过程中实时显示匹配结果，不用输完再回车


--界面交互
opt.wrap = false          -- 关闭长行自动换行：超出屏幕的内容不折行，需要左右滚动查看
opt.mouse = "a"           -- 全模式启用鼠标：普通、插入、可视化模式都支持鼠标点击、滚动、选中文本
opt.clipboard = "unnamedplus" -- 共享系统剪贴板：Neovim 里复制的内容可以直接粘贴到其他软件
opt.termguicolors = true  -- 启用 24 位真彩色：让主题、语法高亮的颜色显示更准确丰富
opt.signcolumn = "yes"    -- 始终显示左侧符号列：用来放报错、断点图标，避免代码左右跳动
opt.scrolloff = 8         -- 光标上下至少保留 8 行可见区域，光标快到边界时自动滚动
opt.sidescrolloff = 8     -- 光标左右至少保留 8 列可见区域
opt.updatetime = 300      -- 编辑器更新间隔（毫秒）：影响插件响应速度，比如语法检查、自动保存
opt.timeoutlen = 400      -- 组合键超时时间（毫秒）：按 Leader 键后，等待下一个按键的最长时间

--代码折叠（za 开关当前折叠，zR 全部展开，zM 全部折叠）
opt.foldmethod = "expr"   -- 折叠方式：按表达式计算（不设置的话默认 manual，za 会提示找不到折叠）
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- 用 Treesitter 语法树识别函数/类/代码块的折叠范围
opt.foldlevel = 99        -- 打开文件时所有折叠默认展开（数字越大展开层级越深）
opt.foldlevelstart = 99   -- 新缓冲区的初始折叠层级，同上
opt.foldtext = ""         -- 折叠行保留语法高亮显示首行内容，而不是灰色的 "+-- N lines" 摘要


--Shell 设置：让 :!命令 和 :terminal 使用 PowerShell 7（Windows 默认是 cmd.exe，没有 ls 等命令）
--下面几个 shellxxx 选项是官方推荐的配套写法（:help shell-powershell），保证输出重定向和编码正确
opt.shell = "pwsh"
opt.shellcmdflag = "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
opt.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
opt.shellquote = ""
opt.shellxquote = ""


--编码设置
opt.encoding = "utf-8"    -- Neovim 内部默认使用 UTF-8 编码
opt.fileencoding = "utf-8"-- 保存文件时默认使用 UTF-8 编码
