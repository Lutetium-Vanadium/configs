local function set_conditional_breakpoint()
    local dap = require('dap')
    local line = vim.fn.line('.')
    local bufnr = vim.api.nvim_get_current_buf()

    -- Get existing breakpoints for current buffer
    local breakpoints = require('dap.breakpoints').get(bufnr)
    local existing_condition = ''

    -- Check if there's a breakpoint on the current line
    if breakpoints then
        local buf_breakpoints = breakpoints[bufnr]
        if buf_breakpoints then
            for _, bp in pairs(buf_breakpoints) do
                if bp.line == line then
                    existing_condition = bp.condition or ''
                    break
                end
            end
        end
    end

    vim.ui.input({ prompt = "Breakpoint condition", default = existing_condition }, function(input)
        if input then
            dap.set_breakpoint(input)
        end
    end)
end

return {
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>dl", function() require("dap").run_last() end,                           desc = "DAP: Run Last" },
            { "<F5>",       function() require("dap").continue() end,                           desc = "DAP: Continue" },
            { "<F6>",       function() require("dap").run_to_cursor() end,                      desc = "DAP: Continue Till Here" },
            { "<F8>",       function() require("dap").step_over() end,                          desc = "DAP: Step Over" },
            { "<F9>",       function() require("dap").step_into() end,                          desc = "DAP: Step Into" },
            { "<F7>",       function() require("dap").step_out() end,                           desc = "DAP: Step Out" },
            { "<leader>dt", function() require("dap").toggle_breakpoint() end,                  desc = "DAP: Toggle Breakpoint" },
            { "<leader>dc", set_conditional_breakpoint,                                         desc = "DAP: Conditional Breakpoint" },
            { "<leader>du", desc = "DAP: Toggle UI" },
            { "<leader>dr", function() require("dap").repl.open() end,                          desc = "DAP: Open REPL" },
            { "<leader>dq", desc = "DAP: Terminate" },
            { "<leader>db", function() require("dap").list_breakpoints() end,                   desc = "DAP: List Breakpoints" },
            { "<leader>de", function() require("dap").set_exception_breakpoints({ "all" }) end, desc = "DAP: Exception Breakpoints" },
        },
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "jay-babu/mason-nvim-dap.nvim",
            "theHamsta/nvim-dap-virtual-text",
            "mfussenegger/nvim-dap-python",
            "julianolf/nvim-dap-lldb",
        },
        config = function()
            local mason_dap = require("mason-nvim-dap")
            local dap = require("dap")
            local ui = require("dapui")
            local dap_virtual_text = require("nvim-dap-virtual-text")

            -- Dap Virtual Text
            dap_virtual_text.setup()

            mason_dap.setup({
                automatic_installation = true,
                handlers = {
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,
                },
            })

            require("dap-python").setup("python3")
            require("dap-lldb").setup({
                configurations = {
                    rust = {
                        name = "Launch Default",
                        type = "codelldb",
                        request = "launch",
                        cwd = '${workspaceFolder}',
                        cargo = {
                            args = { "run" },
                            cwd = "${workspaceFolder}",
                        },
                        stopOnEntry = false,

                    }
                }
            })

            -- Configurations
            table.insert(dap.configurations.python, 1, {
                name = "Python Debugger: API.py",
                type = "python",
                request = "launch",
                program = "${workspaceFolder}/api.py",
                console = "integratedTerminal",
                env = {
                    DEV_MODE = "true"
                }
            })

            local dap_ui_open = false
            local keymap_restore = {}

            local function open_dapui()
                if dap_ui_open then
                    return
                end
                require("dapui").open()
                dap_ui_open = true

                for _, buf in pairs(vim.api.nvim_list_bufs()) do
                    local keymaps = vim.api.nvim_buf_get_keymap(buf, 'n')

                    for _, keymap in pairs(keymaps) do
                        if keymap.lhs == "K" then
                            table.insert(keymap_restore, keymap)
                            vim.api.nvim_buf_del_keymap(buf, 'n', 'K')
                        end
                        if keymap.lhs == "<C-K>" then
                            table.insert(keymap_restore, keymap)
                            vim.api.nvim_buf_del_keymap(buf, 'n', '<C-K>')
                        end
                    end

                    vim.keymap.set('n', 'K', function() require("dap.ui.widgets").hover() end,
                        { silent = true, buffer = buf })
                    vim.keymap.set('n', '<C-K>', vim.lsp.buf.hover,
                        { silent = true, buffer = buf })
                end

                -- Remove statuscolumn https://github.com/folke/snacks.nvim/issues/2534#issuecomment-3567053987
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype:match("^dapui_") then
                        vim.wo[win].statuscolumn = ""
                    end
                end
            end

            local function close_dapui()
                if not dap_ui_open then
                    return
                end

                dap_ui_open = false
                require("dapui").close()
                for _, keymap in pairs(keymap_restore) do
                    if keymap.rhs then
                        vim.api.nvim_buf_set_keymap(
                            keymap.buffer,
                            keymap.mode,
                            keymap.lhs,
                            keymap.rhs,
                            { silent = keymap.silent == 1 }
                        )
                    elseif keymap.callback then
                        vim.keymap.set(
                            keymap.mode,
                            keymap.lhs,
                            keymap.callback,
                            { buffer = keymap.buffer, silent = keymap.silent == 1 }
                        )
                    end
                end
                keymap_restore = {}
            end

            local function toggle_dapui()
                if dap_ui_open then
                    close_dapui()
                else
                    open_dapui()
                end
            end

            -- Dap UI

            -- Allow 'q' to close floating dap windows
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dap-float",
                callback = function()
                    vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close!<CR>", { noremap = true, silent = true })
                    vim.api.nvim_buf_set_keymap(0, "n", "<esc>", "<cmd>close!<CR>", { noremap = true, silent = true })
                end
            })

            ui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "stacks",      size = 0.15 },
                            { id = "scopes",      size = 0.55 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "watches",     size = 0.05 },
                        },
                        position = "left",
                        size = 40
                    },
                    {
                        elements = {
                            { id = "repl",    size = 0.35 },
                            { id = "console", size = 0.65 }
                        },
                        position = "bottom",
                        size = 10
                    }
                },
            })

            vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DebugSign" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DebugSign" })
            vim.fn.sign_define("DapStopped", { text = "→", linehl = "ColorColumn" })

            dap.listeners.before.attach.dapui_config = function()
                open_dapui()
            end
            dap.listeners.before.launch.dapui_config = function()
                open_dapui()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                close_dapui()
            end
            dap.listeners.before.terminated.dapui_config = function()
                if #require("dap").sessions() == 0 then
                    close_dapui()
                end
            end

            -- Keymaps that need access to local functions
            vim.keymap.set("n", "<leader>du", function() toggle_dapui() end, { desc = "DAP: Toggle UI" })
            vim.keymap.set("n", "<leader>dq", function()
                require('dap').terminate({ all = true })
                require("nvim-dap-virtual-text").toggle()
                require("dap.repl").append("Exiting Debugger...")
            end, { desc = "DAP: Terminate" })
        end,
    },
}
