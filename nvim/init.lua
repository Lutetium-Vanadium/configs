require("colourscheme")
-- require("packer_setup")
require("set")
require("filetype-config")
require("config/lazy")
require("remap")

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
local yank_group = augroup('HighlightYank', {})
autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 1000 })
    end,
})

-- -- Format on save
-- local format_group = augroup('FormatOnSave', {})
-- autocmd('BufWritePre', {
--     group = format_group,
--     pattern = '*',
--     callback = function()
--         if vim.lsp.buf.formatting_sync then
--             vim.lsp.buf.formatting_sync()
--         end
--     end,
-- })
