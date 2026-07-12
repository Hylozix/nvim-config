--设置Leader键为空格
vim.g.mapleader = " " --全局设置
vim.g.maplocalleader = " " --局部设置


local keymap = vim.keymap

-- 所有映射共用的选项：noremap 防止递归触发，silent 不在命令行回显
local opts = { noremap = true, silent = true }

keymap.set("i","jj","<ESC>",opts)
keymap.set("n", "H", "^", opts)  -- H 跳转到当前行第一个非空白字符（跳过缩进空格）
keymap.set("n", "J", "5j", opts) -- J 向下连续移动 5 行，等价于按 5 次 j
keymap.set("n", "K", "5k", opts) -- K 向上连续移动 5 行，等价于按 5 次 k
keymap.set("n", "L", "$", opts)  -- L 跳转到当前行最后一个字符（行尾）
keymap.set("v", "H", "^", opts)  -- 选中状态下按 H，选区左端跳到行首
keymap.set("v", "J", "5j", opts) -- 选中状态下按 J，选区向下扩展 5 行
keymap.set("v", "K", "5k", opts) -- 选中状态下按 K，选区向上扩展 5 行
keymap.set("v", "L", "$", opts)  -- 选中状态下按 L，选区右端跳到行尾

-- 普通模式：gp = 粘贴 0 寄存器内容，光标停在粘贴内容末尾（保留原生 gp 的光标特性）
keymap.set("n", "gp", '"0gp', opts)
-- 普通模式：gP = 在光标前上方粘贴 0 寄存器内容，光标停在粘贴内容开头
keymap.set("n", "gP", '"0P', opts)

-- 可视模式：选中内容后按 gp，用 0 寄存器内容直接替换选中部分
keymap.set("v", "gp", '"0gp', opts)
keymap.set("v", "gP", '"0P', opts)
