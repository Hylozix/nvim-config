-- 自动配对：输入 ( [ { " ' 时自动补上闭合符号
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {}, -- 默认配置已足够；会自动和 blink.cmp 协同
}
