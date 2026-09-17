return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle" },
  keys = {
    { "<leader>cr", "<cmd>OverseerRun<cr>", desc = "运行项目任务" },
    { "<leader>ct", "<cmd>OverseerToggle<cr>", desc = "开关任务列表" },
  },
  opts = {},
}
