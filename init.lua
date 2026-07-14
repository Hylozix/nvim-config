--加载编辑器基础设置
require("config.options")
--加载按键映射
require("config.keymaps")
--加载自动命令
require("config.autocmds")
--加载 Neovide 图形界面专属配置（终端里启动时文件开头会直接 return，无副作用）
require("config.neovide")



-------------lazy.nvim插件-------------
-- vim.fn.stdpath("data") 是 Neovim 数据目录，Windows 下对应 %LOCALAPPDATA%\nvim-data\
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 判断本地是否已经存在 lazy.nvim 文件（不存在说明还没安装）
-- vim.uv 是 vim.loop 的新名字，0.10+ 推荐用 vim.uv
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- 调用系统命令，执行 git 克隆操作
  vim.fn.system({
    "git",          -- 调用 git 命令
    "clone",        -- git 子命令：克隆远程仓库
    "--filter=blob:none", -- 过滤大文件，只下载必要内容，大幅加快克隆速度
    "https://github.com/folke/lazy.nvim.git", -- lazy.nvim 的 GitHub 仓库地址
    "--branch=stable", -- 指定克隆 stable 稳定分支，避开开发版的 bug
    lazypath,       -- 克隆到本地的目标路径
  })
end

-- 将 lazy.nvim 的路径加入 Neovim 的「运行时路径」
-- 相当于告诉 Neovim：这里有个插件，你要能找到并运行它
-- prepend 表示加到最前面，优先级最高
vim.opt.rtp:prepend(lazypath)

-- 初始化 lazy.nvim 插件管理器
-- 第一个参数 "plugins" = 自动扫描加载 lua/plugins/ 目录下的所有插件配置
-- 第二个参数是 lazy 自身的配置
require("lazy").setup("plugins", {
  -- 换电脑 clone 后自动补装缺失的插件，不弹提示
  install = { missing = true },
  -- 关闭「配置文件改动自动重载」的提示，避免每次改配置弹窗
  change_detection = { notify = false },
  -- 性能优化：禁用一批用不到的内置 vim 插件，加快启动
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin", -- 用 nvim-tree 代替自带的 netrw 文件浏览器
      },
    },
  },
})
