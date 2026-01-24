return {
    {
        'nikolvs/vim-sunbather',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd('colorscheme sunbather')
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {} -- the place for settings
    },
}
