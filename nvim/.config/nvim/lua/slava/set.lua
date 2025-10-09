vim.g.python3_host_prog = "/usr/bin/python3"

vim.opt.mouse="a"  -- enable mouse set encoding=utf-8
vim.opt.number = true
vim.opt.scrolloff = 8

vim.opt.tabstop=4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.cmdheight = 1

vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.relativenumber = true
vim.opt.fileencoding = "utf-8"

vim.opt.errorbells = false

vim.opt.swapfile = false
vim.opt.backup = false

vim.cmd("syntax off")

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.g.netrw_preview   = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize   = 30
vim.g.netrw_keepdir = 0

vim.g.mapleader = " "

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.py",
    command = "set colorcolumn=79,88"
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.arch",
    command = "UltiSnipsAddFiletypes arch"
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.git/COMMIT_EDITMSG",
    command = "set colorcolumn=50,72"
})

vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*docker-compose*"},
  command = "set filetype=yaml.docker-compose",
})

vim.api.nvim_create_autocmd({"BufEnter", "BufWrite"}, {
    callback = function ()
        vim.schedule(function ()
            local filename = vim.fn.expand('%:p')
            local pat = {
                '.*vars.*%.ya?ml',
                '.*tasks.*%.ya?ml',
                '.*roles.*%.ya?ml',
                '.*handlers.*%.ya?ml',
                '.*playbook.*%.ya?ml',
                'site%.ya?ml',
                'local%.ya?ml',
                'main%.ya?ml',
                'requirements%.ya?ml',
            }

            for i = 1, #pat do
                if string.find(filename, pat[i]) then
                    vim.bo.filetype = 'yaml.ansible'
                    break
                end
            end
        end)
    end,
})

vim.api.nvim_create_user_command('CopyPath', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('✅ Copied to clipboard: ' .. path, vim.log.levels.INFO)
end, {})

vim.keymap.set('n', '<leader>cp', ':CopyPath<CR>', { desc = 'Copy current file path to clipboard' })
