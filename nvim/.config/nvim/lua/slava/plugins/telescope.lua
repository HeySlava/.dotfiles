return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.setup({
            defaults = {
                file_ignore_patterns = { '%.jpg', '%.jpeg', '%.png', '%.git', '%.pdf' },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                }
            }
        })

        telescope.load_extension("fzf")


        local builtin = require('telescope.builtin')

        local function is_git_repo()
          vim.fn.system("git rev-parse --is-inside-work-tree")
          return vim.v.shell_error == 0
        end

        local function get_git_root()
          local dot_git_path = vim.fn.finddir(".git", ".;")
          return vim.fn.fnamemodify(dot_git_path, ":h")
        end

        local project_files = function()
          local opts = {}

          if is_git_repo() then
            opts = {
              cwd = get_git_root(),
              show_untracked = true -- shows untracked files, including dotfiles
            }
            builtin.git_files(opts)
          else
            local client = vim.lsp.get_active_clients()[1]
            if client then
                opts.cwd = client.config.root_dir
            end
            -- shows hidden files for search
            opts.hidden = true
            builtin.find_files(opts)
          end
        end

        vim.keymap.set('n', '<leader>ff', project_files, { desc = "Find Files (Git + Hidden)" })

        vim.keymap.set('n', '<leader>fg', function()
             local opts = {}
             if is_git_repo() then opts.cwd = get_git_root() end
             builtin.live_grep(opts)
        end, {})

        vim.keymap.set('n', '<leader>fn', function()
            builtin.find_files({ cwd = '~/.dotfiles', hidden = true })
        end, {})

        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>fs', builtin.grep_string, {}) -- Find String under cursor
        vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = "Resume last search" })
    end
}
