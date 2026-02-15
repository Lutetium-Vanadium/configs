return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            explorer = { enabled = true },
            input = {
                enabled = true,
            },
            image = {
                enabled = true,
            },
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            picker = { enabled = true },
            quickfile = { enabled = true },
            statuscolumn = {
                left = { "sign", "mark", "fold", "git" },
                right = {},
                enabled = true
            },
            styles = {
                input = {
                    relative = "cursor",
                },
            },
        },
        keys = {
            { "<leader><C-d>", function() require("snacks").bufdelete() end, desc = "Bufdelete" },
            { "<leader>b",     function() require("snacks").explorer() end,  desc = "Toggle Neo-tree" },
        }
    },
}
