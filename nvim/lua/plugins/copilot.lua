local utils = require("utils")

return {
    {
        "zbirenbaum/copilot-cmp",
        dependencies = {
            "hrsh7th/nvim-cmp",
        },
        config = function()
            -- Make sure to load cmp
            require('cmp')
            require("copilot_cmp").setup()
        end
    },
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        dependencies = {
            "zbirenbaum/copilot-cmp",
            "nvim-lualine/lualine.nvim",
        },
        enabled = function() return not utils.is_git_file() end,
        opts = {
            cmd = "Copilot",
            panel = { enabled = false },
            suggestion = { auto_trigger = false },
            filetypes = {
                sh = function()
                    if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                        -- disable for .env files
                        return false
                    end
                    return true
                end,
                help = false,
                gitcommit = false,
                gitrebase = false,
                hgcommit = false,
                svn = false,
                cvs = false,
                ["."] = false,
            },
            on_status_update = function() require("lualine").refresh() end,
        },
    },
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {
            "folke/snacks.nvim",
        },
        config = function()
            ---@type opencode.Opts
            vim.g.opencode_opts = {
                provider = {
                    enabled = "tmux",
                    tmux = {
                        -- ...
                    }
                }
            }

            -- Required for `opts.events.reload`.
            vim.o.autoread = true

            -- Recommended/example keymaps.
            vim.keymap.set({ "n", "x" }, "<leader>ca",
                function() require("opencode").ask("@this: ", { submit = true }) end,
                { desc = "Ask opencode" })
            vim.keymap.set({ "n", "x" }, "<leader>cx", function() require("opencode").select() end,
                { desc = "Execute opencode action…" })
            vim.keymap.set({ "n", "t" }, "<leader>co", function() require("opencode").toggle() end,
                { desc = "Toggle opencode" })

            vim.keymap.set({ "n", "x" }, "<leader>cr", function() return require("opencode").operator("@this ") end,
                { expr = true, desc = "Add range to opencode" })
            vim.keymap.set("n", "<leader>cl", function() return require("opencode").operator("@this ") .. "_" end,
                { expr = true, desc = "Add line to opencode" })

            vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
                { desc = "opencode half page up" })
            vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
                { desc = "opencode half page down" })
        end,
    },
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        enabled = false, -- function() return not utils.is_git_file() end,
        build = "env -u CARGO_TARGET_DIR make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "MeanderingProgrammer/render-markdown.nvim",
            "HakonHarnes/img-clip.nvim",
            "folke/snacks.nvim",
        },
        opts = {
            provider = "copilot",
            mode = "agentic",
            behaviour = {
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = true,
                auto_add_current_file = true,
                auto_approve_tool_permissions = {
                    "rag_search", "git_diff", "glob", "search_keyword", "read_file_toplevel_symbols", "read_file",
                    "create_file", "copy_path", "create_dir", "replace_in_file",

                    -- Extracted from http request sent to Copilot
                    "dispatch_agent", "ls", "grep", "delete_tool_use_message", "read_todos", "write_todos",
                    "str_replace", "view", "write_to_file", "insert", "undo_edit", "think", "get_diagnostics",
                    "attempt_completion", "web_search", "fetch", "read_definitions", "add_file_to_context",
                    "remove_file_from_context",
                },
            },
            prompt_logger = {
                enabled = true,
                log_dir = vim.fn.stdpath("cache") .. "/avante_prompts",
                fortune_cookie_on_success = false,
                next_prompt = {
                    normal = "<C-n>",
                    insert = "<C-n>",
                },
                prev_prompt = {
                    normal = "<C-p>",
                    insert = "<C-p>",
                },
            },
            mappings = {
                diff = {
                    ours = "co",
                    theirs = "ct",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                    next = "]x",
                    prev = "[x",
                },
                suggestion = {
                    accept = "<C-y>",
                    next = "<leader>]",
                    prev = "<leader>[",
                    dismiss = "<C-c>",
                },
                jump = {
                    next = "]]",
                    prev = "[[",
                },
                submit = {
                    normal = "<CR>",
                    insert = "<C-s>",
                },
                cancel = {
                    normal = { "<C-c>", "<Esc>", "q" },
                    insert = { "<C-c>" },
                },
                sidebar = {
                    apply_all = "A",
                    apply_cursor = "a",
                    retry_user_request = "r",
                    edit_user_request = "e",
                    switch_windows = "<Tab>",
                    reverse_switch_windows = "<S-Tab>",
                    remove_file = "d",
                    add_file = "@",
                    close = { "q" },
                    close_from_input = nil,
                },
            },
            windows = {
                width = 40,
            },
            providers = {
                copilot = {
                    model = "claude-sonnet-4.5"
                },
            }
        },
    },
}
