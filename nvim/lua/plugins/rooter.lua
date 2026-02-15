return {
    {
        "airblade/vim-rooter",
        lazy = false,
        init = function()
            -- Remove Makefile as they might occur within sub-directories also
            vim.g.rooter_patterns = { '.git/', '_darcs', '.hg', '.bzr', '.svn', 'Cargo.lock' }
        end,
    },
}
