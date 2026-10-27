return {
    "danymat/neogen",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        -- C# 平时由 Roslyn 生成（config/csharp_doc.lua）；Roslyn 还没连上时
        -- 退回 neogen，至少用 /// <summary> 格式而不是默认的 Doxygen
        languages = {
            cs = { template = { annotation_convention = "xmldoc" } },
        },
    },
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
