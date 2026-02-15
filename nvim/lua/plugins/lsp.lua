local kind_icons = {
    Text = "󰊄",
    Method = "󰊕",
    Function = "󰊕",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Copilot = "",
}

return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require('cmp')
            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                sources = {
                    { name = "copilot", group_index = 2 },
                    { name = 'nvim_lsp' },
                    { name = 'path' },
                    { name = 'buffer',  keyword_length = 3 },
                    { name = "lazydev", group_index = 0 },
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            copilot = "[Copilot]",
                            lazydev = "[LazyDev]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                }),
            })
        end
    },
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- Setup LSP keymaps and autocommands on attach
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)

                    -- Stop eslint if it attaches
                    if client and client.name == "eslint" then
                        vim.lsp.stop_client(client.id)
                        return
                    end

                    local opts = { buffer = event.buf, remap = false }
                    local builtin = require("telescope.builtin")

                    -- LSP keymaps
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set({ "i", "n" }, "<C-k>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>g", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "[g", function() vim.diagnostic.jump({ count = -1 }) end, opts)
                    vim.keymap.set("n", "]g", function() vim.diagnostic.jump({ count = 1 }) end, opts)

                    -- Telescope keymaps
                    vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
                    vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
                    vim.keymap.set("n", "gr", builtin.lsp_references, opts)

                    if not client.server_capabilities.documentHighlightProvider then
                        return
                    end

                    -- highlight groups for references
                    vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'HoverHighlight' })
                    vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'HoverHighlight' })
                    vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'HoverHighlight' })

                    local group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. event.buf, { clear = true })

                    -- normal mode + visual mode (CursorHold triggers in both)
                    vim.api.nvim_create_autocmd('CursorHold', {
                        group = group,
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    -- clear when moving cursor (normal/visual)
                    vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
                        group = group,
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end,
            })

            -- Get default capabilities for LSP servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', {}, capabilities, require('cmp_nvim_lsp').default_capabilities())

            -- Custom setup for rust_analyzer
            vim.lsp.config('rust_analyzer', {
                capabilities = capabilities,
                cmd = { 'rust-analyzer' },
                filetypes = { 'rust' },
                root_markers = { 'Cargo.toml', 'rust-project.json' },
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            features = "all",
                        },
                    },
                },
            })

            -- Setup mason-lspconfig to ensure servers are installed and auto-enable them
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'lua_ls',
                    'rust_analyzer',
                    'ts_ls',
                    'pyright',
                },
                handlers = {
                    function(server_name)
                        -- Skip servers we already setup manually above
                        if server_name == "ts_ls" or server_name == "rust_analyzer" then
                            return
                        end
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,
                }
            })

            -- Diagnostic configuration
            vim.diagnostic.config({
                virtual_text = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '✘',
                        [vim.diagnostic.severity.WARN] = '',
                        [vim.diagnostic.severity.HINT] = '󰮥',
                        [vim.diagnostic.severity.INFO] = 'i',
                    },
                },
            })
        end,
    },
    {
        'stevearc/conform.nvim',
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            log_level = vim.log.levels.DEBUG,
            formatters_by_ft = {
                python = { "black", "isort" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 2000,
                lsp_fallback = true,
            },
        },
    },
}
