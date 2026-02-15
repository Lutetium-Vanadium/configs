local utils = require('utils')

return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.3",
        cmd = "Telescope",
        keys = {
            { "<C-p>",     desc = "Find files (proximity sort)" },
            { "<leader>p", desc = "Find files (proximity sort)" },
            { "<C-n>",     desc = "Find all files (including hidden)" },
            { "<leader>s", "<cmd>Telescope live_grep<cr>",            desc = "Live grep" },
            { "<leader>;", "<cmd>Telescope buffers<cr>",              desc = "Buffers" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                },
                pickers = {
                    lsp_references = {
                        path_display = { "smart" },
                    },
                    buffers = {
                        show_all_buffers = true,
                        sort_lastused = true,
                        mappings = {
                            i = {
                                ["<c-d>"] = "delete_buffer",
                            },
                            n = {
                                ["d"] = "delete_buffer",
                            }
                        }
                    }
                }
            })

            local builtin = require('telescope.builtin')
            local sorters = require "telescope.sorters"

            local function get_file_score(file_path, base_path)
                if base_path == '.' then
                    return 0
                end

                -- Split paths into directory components
                local file_parts = {}
                for part in string.gmatch(file_path, "[^/]+") do
                    table.insert(file_parts, part)
                end

                local base_parts = {}
                for part in string.gmatch(base_path, "[^/]+") do
                    table.insert(base_parts, part)
                end

                -- Find common prefix length
                local common_length = 0
                for i = 1, math.min(#file_parts - 1, #base_parts - 1) do
                    if file_parts[i] == base_parts[i] then
                        common_length = i
                    else
                        break
                    end
                end

                -- Distance = directories to go up from base + directories to go down to file
                local distance = (#base_parts - 1 - common_length) + (#file_parts - 1 - common_length)
                return distance
            end

            -- A file picker that sorts entries based on the proximity of files relative to
            -- the file path of the current buffer.
            -- Requires the `proximity-sort` and `fd` binaries to be present.
            local function get_proximity_sorter(base_path, opts)
                opts = opts or {}
                local fuzzy_sorter = sorters.get_fuzzy_file(opts)
                local fzy = opts.fzy_mod or require "telescope.algos.fzy"

                return sorters.Sorter:new {
                    discard = true,

                    scoring_function = function(_, prompt, line)
                        -- Check for actual matches before running the scoring alogrithm.
                        if not fzy.has_match(prompt, line) then
                            return -1
                        end

                        local fuzzy_score = fuzzy_sorter.scoring_function(
                            fuzzy_sorter, prompt, line)

                        if fuzzy_score == -1 then
                            return -1
                        end
                        local proximity_score = get_file_score(line, base_path) / 100

                        return fuzzy_score + proximity_score
                    end,

                    highlighter = function(_, prompt, display)
                        return fzy.positions(prompt, display)
                    end,
                }
            end

            vim.keymap.set('n', '<C-p>', function()
                builtin.find_files({
                    sorter = get_proximity_sorter(utils.get_relative_file_path())
                })
            end)
            vim.keymap.set('n', '<leader>p', function()
                builtin.find_files({
                    sorter = get_proximity_sorter(utils.get_relative_file_path())
                })
            end)
            vim.keymap.set('n', '<C-n>', function()
                builtin.find_files({
                    hidden = true, no_ignore = true, no_ignore_parent = true
                })
            end)
            vim.keymap.set('n', '<leader>s', builtin.live_grep)
            vim.keymap.set('n', '<leader>;', builtin.buffers)
        end,
    },
}
