-- SVN 改动标记：在左侧符号列显示增/删/改（相当于"多版本控制版 gitsigns"）
-- 支持 svn/hg/bzr 等十几种版本控制，这里限制它只管 svn，git 仓库继续由 gitsigns 负责，
-- 避免两个插件在 git 项目里重复画标记
return {
  "mhinz/vim-signify",
  event = { "BufReadPre", "BufNewFile" },
  -- init 在插件加载前执行：vim-signify 是 VimScript 插件，靠全局变量配置，
  -- 必须在它加载前设好（写在 config 里就晚了）
  init = function()
    -- 白名单：只允许 svn（默认会检测所有支持的版本控制系统）
    vim.g.signify_skip = { vcs = { allow = { "svn" } } }
    -- 符号样式与 gitsigns 视觉统一
    vim.g.signify_sign_add = "┃"
    vim.g.signify_sign_change = "┃"
    vim.g.signify_sign_delete = "▁"
    vim.g.signify_sign_delete_first_line = "▔"
    -- 行内有多处修改时不在符号后面叠加数字，保持整洁
    vim.g.signify_sign_show_count = false
  end,
}
