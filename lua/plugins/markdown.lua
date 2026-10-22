return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = { max_file_size = 1.0 },
  },
  {
    "SCJangra/table-nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      mappings = {
        next = "<M-n>",
        prev = "<M-p>",
        insert_table = "<leader>mt",
        insert_table_alt = false,
      },
    },
    config = function(_, opts)
      require("table-nvim").setup(opts)
      require("table-nvim.keymaps").set_keymaps(vim.api.nvim_get_current_buf())
    end,
  },
}
