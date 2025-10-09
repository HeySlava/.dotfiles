local map = vim.api.nvim_set_keymap
local noremap = { noremap = true }

local actions = require('telescope.actions')

require('telescope').setup {
  extensions = {
    fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  },
  defaults = {
    layout_config = {
        width = 0.99,
        prompt_position = "top",
        preview_cutoff = 120,
        horizontal = {mirror = false},
        vertical = {mirror = false}
    },
    file_ignore_patterns = { '%.jpg', '%.jpeg', '%.png',
                             '%.otf', '%.ttf', '%.git',
                             '%.pdf', '%.gif' },
    find_command = {
        'rg',
        '--column',
        '--hidden',
        '--ignore-file',
        '--line-number',
        '--no-heading',
        '--smart-case',
        '--with-filename',
        '-L',
    },
    vimgrep_arguments = {
      "rg",
      "--column",
      "--hidden",
      "--line-number",
      "--no-heading",
      "--smart-case",
      "--with-filename",
    },
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    file_sorter = require'telescope.sorters'.get_fuzzy_file,
    generic_sorter = require'telescope.sorters'.get_generic_fuzzy_sorter,
    path_display = {},
    winblend = 0,
    border = {},
    borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
    color_devicons = true,
    use_less = true,
    set_env = {['COLORTERM'] = 'truecolor'}, -- default = nil,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
    mappings = {
        i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,

            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,

            ["<C-c>"] = actions.close,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,

            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,

            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
        },

        n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,

            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,

            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,

            ["?"] = actions.which_key,
        },
    },
},
}


local builtin = require('telescope.builtin')

local function is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

local function get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end


local default = {
    column = true,
    hidden = true,
    ["line-number"] = true,
    ["no-heading"] = true,
    ["smart-case"] = true,
    ["with-filename"] = true,
    L = true,
}


local find_files_from_project_git_root = function()
  local modified_default = {}

  for k, v in pairs(default) do
    modified_default[k] = v
  end

	if is_git_repo() then
        modified_default['cwd'] = get_git_root()
	end
  builtin.find_files(modified_default)
end


local live_grep_from_project_git_root = function()
  local modified_default = {}

  for k, v in pairs(default) do
    modified_default[k] = v
  end

	if is_git_repo() then
        modified_default['cwd'] = get_git_root()
	end
	builtin.live_grep(modified_default)
end


local get_dot_files = function ()
    builtin.find_files({ cwd = '~/.dotfiles', hidden = true,})
end

-- Telescope
-- map('n', '<leader>ff', '<cmd>lua vim.find_files_from_project_git_root()<cr>', noremap)
vim.keymap.set('n', '<leader>ff', find_files_from_project_git_root, {})
vim.keymap.set('n', '<leader>fn', get_dot_files, {})
-- map('n', '<leader>fn', '<cmd>Telescope find_files cwd=~/.dotfiles/ find_command=rg,--hidden,-L,--files<cr>', noremap)
vim.keymap.set('n', '<leader>fg', live_grep_from_project_git_root, noremap)
map('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', noremap)
map('n', '<leader>fm', '<cmd>Telescope marks<cr>', noremap)
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', noremap)
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', noremap)




require('telescope').load_extension('fzf')
