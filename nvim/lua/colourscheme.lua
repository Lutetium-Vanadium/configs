function MonokaiCustom()
    vim.cmd.colorscheme("own-colourscheme")

    vim.cmd('hi link TelescopeNormal NormalFloat')
    vim.cmd('hi link TelescopeBorder Normal')
    vim.cmd('hi link TelescopePreviewNormal NormalFloat')
    vim.cmd('hi link TelescopeResultsNormal NormalFloat')
    vim.cmd("syntax on")
    vim.cmd("hi Normal guibg=None")
    vim.cmd("hi NonText guibg=None")
    vim.cmd("hi LineNr guibg=None")
end

MonokaiCustom()
