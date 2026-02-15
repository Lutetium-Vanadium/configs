vim.keymap.set("n", ";", ":")

-- Nicer navigation
vim.keymap.set("n", "<leader><leader>", "<c-^>")
---- Home and End should use home row
vim.keymap.set({ "n", "v", "o", }, "H", "^")
vim.keymap.set({ "n", "v", "o", }, "L", "$")
---- Easy switch between buffers
vim.keymap.set("n", "<left>", vim.cmd.bp)
vim.keymap.set("n", "<right>", vim.cmd.bn)
---- Move by line
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
---- Replace till next _ or -
vim.keymap.set("n", "<leader>m", "ct_")
vim.keymap.set("n", "<leader>e", ':e <C-R>=expand("%:p:h") . "/" <CR>')

-- Quick-save
vim.keymap.set("n", "<leader>w", vim.cmd.w)

-- Search and replace
vim.keymap.set("n", "<leader>r", ":%sm/")

-- Multi-plexing
vim.keymap.set({ "n", "v", "o", }, "<leader>|", vim.cmd.vsplit)
vim.keymap.set({ "n", "v", "o", }, "<leader>-", vim.cmd.split)
vim.keymap.set({ "n", "v", "o", }, "<leader>h", "<C-W>h")
vim.keymap.set({ "n", "v", "o", }, "<leader>j", "<C-W>j")
vim.keymap.set({ "n", "v", "o", }, "<leader>k", "<C-W>k")
vim.keymap.set({ "n", "v", "o", }, "<leader>l", "<C-W>l")

-- Move blocks when highlighted
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Send to void (aka do not copy when replacing/deleting)
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Search results centered
vim.keymap.set("n", "<silent> n", "nzz")
vim.keymap.set("n", "<silent> N", "Nzz")
vim.keymap.set("n", "<silent> *", "*zz")
vim.keymap.set("n", "<silent> #", "#zz")
vim.keymap.set("n", "<silent> g*", "g*zz")

-- Magic by default
vim.keymap.set("n", "?", "?\\v")
vim.keymap.set("n", "/", "/\\v")
vim.keymap.set("c", "%s/", "%sm/")

-- Let cursor stay where it is when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Show invisible characters
vim.keymap.set("n", "<leader>,", function() vim.cmd.set("invlist") end)

-- Show stats
vim.keymap.set("n", "<leader>q", "g<c-g>")

-- Disable F1 (help)
vim.keymap.set({ "n", "i", "s" }, "<F1>", "<Nop>")
