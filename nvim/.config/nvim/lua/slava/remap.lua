local map = vim.keymap.set
local noremap = {noremap = true}


map('n', '<leader>e', ':Lexplore<CR>', { silent = true, desc = "Toggle file explorer" })


map('n', '<leader>pt', ':w !python3<CR>', noremap)
map('n', '<leader>la', ':w !lua<CR>', noremap)
map('i', 'jk', '<ESC>', noremap)
map('n', 'Y', 'y$', noremap)

-- turn off hlsearch
map('n', ',<leader>', ':nohlsearch<CR>', noremap)

-- save file
map('n', '<leader>w', ':w! <cr>', noremap)

-- do not copy in unnamed buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- git
map('n', '<leader>gf', ':diffget //2<CR>', noremap)
map('n', '<leader>gj', ':diffget //3<CR>', noremap)
map('n', '<leader>gs', ':G<CR>', noremap)

-- syntax maping
map('n', '<leader>so', ':syntax on<cr>', noremap)
map('n', '<leader>sf', ':syntax off<cr>', noremap)


map('n', '<leader>t', '<Plug>MarkdownPreviewToggle', noremap)


map('i', '<F1>', '<Nop>', noremap)
map('n', '<F1>', '<Nop>', noremap)


vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Safe and reliable for quickfix navigation
vim.keymap.set('n', '<C-n>', ':cnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', ':cprev<CR>', { noremap = true, silent = true })
