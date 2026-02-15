return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require('nvim-autopairs').setup {}

            -- If you want insert `(` after select function or method item
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )

            local Rule = require('nvim-autopairs.rule')
            local npairs = require('nvim-autopairs')
            local cond = require('nvim-autopairs.conds')

            -- Generate <> pair for generic arguments. Pair is only generated if after a word
            npairs.add_rule(
                Rule("<", ">", "rust"):with_pair(cond.before_regex_check("[_a-zA-Z0-9]"))
            )
        end,
    },
}

