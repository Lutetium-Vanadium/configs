return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            file_types = { 'markdown', "md", "Avante" },
            code = {
                -- Make sure lsp extmarks are higher
                priority = 100
            }
        },
        config = function(_, opts)
            require('render-markdown').setup(opts)

            vim.api.nvim_create_autocmd("InsertEnter", {
                pattern = "*.md",
                callback = function()
                    require('render-markdown').buf_disable()
                end,
            })
        end
    }
}
