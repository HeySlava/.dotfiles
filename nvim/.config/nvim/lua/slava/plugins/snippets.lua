return {
    {
        'SirVer/ultisnips',
        dependencies = {'honza/vim-snippets'},
        init = function()
            vim.g.UltiSnipsExpandTrigger="<tab>"
            vim.g.UltiSnipsListSnippets="<c-l>"
            vim.g.UltiSnipsEditSplit="vertical"
        end
    },
}
