return {
    "danymat/neogen",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = true,
    keys = {
        {
            "<leader>ng",
            function()
                require("neogen").generate()
            end,
            desc = "Generate documentation",
        },
    },
}
