require('telescope').setup {
    defaults = {
        -- layout_strategy = 'bottom_pane',
        layout_config = {
            height = 0.4,
        },
        results_title = false,
        preview_title = false,
        border = {
            -- prompt = { 1, 1, 1, 1 },
            -- results = { 1, 1, 1, 1 },
            -- preview = { 1, 1, 1, 1 },
        },
        borderchars = {
            -- prompt = { "─", " ", "─", " ", "─", "─", "─", "─" },
            prompt = { "╌", " ", "╌", " ", "╌", "╌", "╌", "╌" },
            results = { "", "", "", "", "", "", "", "" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        sorting_strategy = "ascending",
    },
}

-- File browser
require('telescope').setup {
    extensions = {
        file_browser = {
            hijack_netrw = true,
            display_stat = false,
            dir_icon = " ",
        },
    },
}
vim.keymap.set("n", "g-", function()
    require("telescope").extensions.file_browser.file_browser({
        path = '%:p:h',
        select_buffer = true,
    }
    )
end)
vim.keymap.set("n", "-", function()
    require("telescope").extensions.file_browser.file_browser()
end)

require("telescope").load_extension('file_browser') -- File browser
require("telescope").load_extension('ui-select')    -- Better UI picker globally
if vim.fn.has('win32') == 0 then
    require('telescope').load_extension('fzf')      -- Faster Fzf (requires `make`)
end

-- Custom picker for visible files
local function list_visible_files()
    local api = vim.api
    local current_win = api.nvim_get_current_win()
    local current_buf = api.nvim_get_current_buf()

    -- Get the range of visible lines
    local topline = api.nvim_win_get_cursor(current_win)[1] - vim.fn.line('w0')
    local botline = topline + vim.fn.line('w$') - 1

    -- Extract lines in the visible range
    local lines = api.nvim_buf_get_lines(current_buf, topline, botline, false)

    -- Pattern to match file paths (adjust as needed)
    local file_pattern = "%S+"

    -- Table to store matched file paths
    local files = {}

    -- Search for file paths in the visible lines
    for _, line in ipairs(lines) do
        for file in line:gmatch(file_pattern) do
            -- Check if the file exists
            if vim.fn.filereadable(file) == 1 then
                table.insert(files, file)
            end
        end
    end

    -- Use Telescope to display the files
    require('telescope.pickers').new({}, {
        prompt_title = 'Visible Files',
        finder = require('telescope.finders').new_table {
            results = files,
        },
        sorter = require('telescope.config').values.generic_sorter({}),
        attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
                local selection = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                vim.cmd('edit ' .. selection[1])
            end)
            return true
        end,
    }):find()
end

-- Keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<space>gf', list_visible_files, { desc = 'Telescope list visible files' })
vim.keymap.set('n', '<space>\\', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<space>*', builtin.grep_string,
    { desc = 'Telescope: Searches for the string under your cursor or selection in your current working directory' })
vim.keymap.set('n', '<space>/', builtin.current_buffer_fuzzy_find, { desc = 'Telescope current buffer grep' })
vim.keymap.set('n', '<space>b', builtin.buffers, { desc = 'Telescope buffers' })
require('telescope').setup {
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<C-x>"] = require('telescope.actions').delete_buffer,
                    ["<C-s>"] = require('telescope.actions').select_horizontal,
                },
            },
        },
    },
}
vim.keymap.set('n', '<space>h', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<space><space>', builtin.resume, { desc = 'Telescope resume last call' })

vim.keymap.set('n', '<space>r', builtin.lsp_references, { desc = 'Telescope LSP references' })
vim.keymap.set('n', '<space>d', builtin.lsp_definitions, { desc = 'Telescope LSP definition(s)' })
vim.keymap.set('n', '<space>i', builtin.lsp_implementations, { desc = 'Telescope LSP implementation(s)' })

vim.keymap.set('n', '<C-Space>', builtin.builtin, { desc = 'Telescope actions' })
