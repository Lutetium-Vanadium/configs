return {
    {
        "tanvirtin/monokai.nvim",
        lazy = true,
        config = function()
            local monokai = require('monokai')
            local palette = monokai.classic

            palette.white = '#dddddd';
            palette.red = '#e73c50';
            palette.pink = palette.red;

            monokai.setup {
                italics = false,
                palette = palette,
                custom_hlgroups = {
                    ["@include"] = { fg = palette.red },
                    ["@conditional"] = { fg = palette.red },
                    ["@annotation"] = { fg = palette.aqua },
                    ["@comment.doc"] = { fg = palette.aqua },
                    ["@constant"] = { fg = palette.white },
                    ["@type"] = { fg = palette.white },
                    ["@type.builtin"] = { fg = palette.aqua },
                    ["@type.qualifier"] = { fg = palette.aqua },
                    ["@constructor"] = { fg = palette.green },
                    ["@variable.builtin"] = { fg = palette.purple },
                    ["@paramater"] = { fg = palette.aqua },
                    ["@namespace"] = { fg = palette.red },
                    ["@storageclass.lifetime"] = { fg = palette.purple },
                    ["@keyword.operator"] = { fg = palette.purple },
                    ["@exception.rust"] = { fg = palette.green },
                    ["@text.todo"] = { fg = palette.orange, style = 'bold' },
                }
            }

            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
            vim.api.nvim_set_hl(0, "LineNr", { fg = palette.base3, bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end,
    },
    {
        "custom/own-colourscheme",
        dir = vim.fn.stdpath("config") .. "/colors",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("own-colourscheme")

            vim.cmd('hi link TelescopeNormal NormalFloat')
            vim.cmd('hi link TelescopeBorder Normal')
            vim.cmd('hi link TelescopePreviewNormal NormalFloat')
            vim.cmd('hi link TelescopeResultsNormal NormalFloat')
            vim.cmd("syntax on")
            vim.cmd("hi Normal guibg=None")
            vim.cmd("hi NonText guibg=None")
            vim.cmd("hi LineNr guibg=None")
        end,
    },
}

