return {
  "sindrets/winshift.nvim",
  cmd = "WinShift",
  keys = {
    {
      "<C-w>X",
      function()
        local restore_sizes = vim.fn.winrestcmd()
        vim.cmd("WinShift swap")
        vim.cmd(restore_sizes)
      end,
      desc = "选择窗口交换",
    },
  },
  opts = {},
}
