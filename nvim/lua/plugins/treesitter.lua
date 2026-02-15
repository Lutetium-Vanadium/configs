local utils = require('utils')

return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        lazy = false,
        branch = "master",
        enabled = function() return not utils.is_git_file() end,
        build = ":TSUpdate",
        config = function()
            require 'nvim-treesitter.configs'.setup {
                -- A list of parser names, or "all"
                ensure_installed = { "javascript", "typescript", "c", "lua", "rust", "comment", "python" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                highlight = {
                    enable = true,
                    disable = { 'tmux' },
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },
            }

            vim.api.nvim_set_hl(0, '@comment.error.comment', { link = 'CommentError' })
            vim.api.nvim_set_hl(0, '@comment.note.comment', { link = 'CommentNote' })
            vim.api.nvim_set_hl(0, '@comment.todo.comment', { link = 'CommentTodo' })

            vim.api.nvim_set_hl(0, '@module', { link = '@variable' })
            vim.api.nvim_set_hl(0, '@function.builtin', { link = 'Type' })
            vim.api.nvim_set_hl(0, '@type.builtin', { fg = '#66d9ef', italic = true })

            vim.api.nvim_set_hl(0, '@tag.builtin', { link = 'Tag' })
            vim.api.nvim_set_hl(0, '@tag.tsx', { link = 'Type' })
            vim.api.nvim_set_hl(0, '@tag.delimiter', { fg = 'white' })
            vim.api.nvim_set_hl(0, '@punctuation.delimiter', { fg = 'white' })
            vim.api.nvim_set_hl(0, '@tag.attribute', { link = 'Function' })

            vim.api.nvim_set_hl(0, '@constructor.python', { link = 'Type' })
            vim.api.nvim_set_hl(0, '@constructor.python', { link = 'Type' })

            vim.api.nvim_set_hl(0, '@property.json', { link = 'Type' })
            vim.api.nvim_set_hl(0, '@property.jsonc', { link = 'Type' })
            vim.api.nvim_set_hl(0, '@property.yaml', { link = 'Type' })
            vim.api.nvim_set_hl(0, '@property.toml', { link = 'Type' })

            vim.api.nvim_set_hl(0, '@module.rust', { link = 'Include' })
            vim.api.nvim_set_hl(0, '@punctuation.delimiter.rust', { link = 'Delimiter' })
            vim.api.nvim_set_hl(0, '@comment.documentation.rust', { link = 'SpecialComment' })

            vim.api.nvim_set_hl(0, '@lsp.type.namespace', { link = 'Include' })
            vim.api.nvim_set_hl(0, '@lsp.typemod.comment.documentation.rust', { link = '@comment.documentation.rust' })
            vim.api.nvim_set_hl(0, '@lsp.type.macro.rust', { link = 'Function' })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        enabled = function() return not utils.is_git_file() end,
        opts = {
            enable = true,           -- Enable this plugin (Can be enabled/disabled later via commands)
            multiwindow = false,     -- Enable multiwindow support.
            max_lines = 5,           -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0,   -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 2, -- Maximum number of lines to show for a single context
            trim_scope = 'outer',    -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = 'cursor',         -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = nil,
            zindex = 20,     -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        }
    }
}
