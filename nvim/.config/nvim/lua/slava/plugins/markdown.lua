return {
    {
        'plasticboy/vim-markdown',
        ft = { "markdown" },
        init = function()
            vim.g.vim_markdown_folding_disabled = 1
            vim.g.conceallevel = 2
            vim.g.vim_markdown_no_extensions_in_markdown = 1
        end
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        keys = {
            { "<leader>t", "<Plug>MarkdownPreviewToggle", desc = "Markdown Preview" }
        }
    },
}
