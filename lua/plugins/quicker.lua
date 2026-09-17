return {
  "stevearc/quicker.nvim",
  ft = "qf",
  keys = {
    { "<leader>q", function() require("quicker").toggle() end, desc = "开关结果列表" },
  },
  opts = {
    keys = {
      { ">", function() require("quicker").expand({ before = 2, after = 2 }) end, desc = "展开上下文" },
      { "<", function() require("quicker").collapse() end, desc = "收起上下文" },
    },
  },
}
