-----------------
-- Colorscheme --
-----------------

-- Apply colorcheme
vim.o.termguicolors = false
vim.cmd("colorscheme ubesluttsom")

---------------
-- lazy.nvim --
---------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
local lazy = require("lazy")
lazy.setup({
    { "airblade/vim-gitgutter" },
    { "jeffkreeftmeijer/vim-dim" },
    { "junegunn/vim-easy-align" },
    { "junegunn/vim-peekaboo" },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-treesitter/nvim-treesitter-context" },
    { "lukas-reineke/lsp-format.nvim" },
    { "mfussenegger/nvim-lint" },
    { "mhartington/formatter.nvim" },
    { "neovim/nvim-lspconfig" },
    { "tpope/vim-commentary" },
    { "tpope/vim-fugitive" },
    { "tpope/vim-repeat" },
    { "tpope/vim-unimpaired" },
    { "tpope/vim-surround" },
    { "tpope/vim-speeddating" },
    { "wellle/targets.vim" },
    {
        "williamboman/mason.nvim",
        opts = {
            ui = {
                border = "single",
            },
        },
    },
    { "williamboman/mason-lspconfig.nvim" },
    { "kaarmu/typst.vim",                 ft = "typst", lazy = false },
    { "folke/twilight.nvim",
        opts = {
            {
                dimming = {
                    alpha = 0.25, -- amount of dimming
                    -- we try to get the foreground from the highlight groups or fallback color
                    color = { "Normal", "#ffffff" },
                    term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
                    inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
                },
                context = 10, -- amount of lines we will try to show around the current line
                treesitter = true, -- use treesitter when available for the filetype
                -- treesitter is used to automatically expand the visible text,
                -- but you can further control the types of nodes that should always be fully expanded
                expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
                    "function",
                    "method",
                    "table",
                    "if_statement",
                },
                exclude = {}, -- exclude these filetypes
            }
        }
    },
    -- TODO: Fix MCP. It seems cool
    -- {
    --     "ravitemer/mcphub.nvim",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --     },
    --     build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    --     config = function()
    --         require("mcphub").setup()
    --     end
    -- }
})


----------------------
-- General settings --
----------------------

-- Scroll-off
vim.o.scrolloff = 10

-- Use ripgrep
vim.o.grepprg = "rg --vimgrep --smart-case"
vim.o.grepformat = "%f:%l:%c:%m"

-- Splits and windows
vim.o.equalalways = false
vim.o.splitright = true
vim.o.splitbelow = true

-- Key mappings
vim.api.nvim_set_keymap('t', '<C-W>', '<C-\\><C-N><C-W>', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-^>', '<C-\\><C-N><C-^>', { noremap = true })
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-N>', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-\\><Esc>', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('n', 'y"*', ':let @*=@" \\| echo "\"-register yanked to system clipboard!"<CR>',
    { noremap = true, silent = true })

-- Search for word under cursor without moving (exact word match)
vim.keymap.set('n', '§', function()
    vim.fn.setreg('/', '\\<' .. vim.fn.expand('<cword>') .. '\\>')
    vim.opt.hlsearch = true
end)

-- Search for word under cursor without moving (partial word match)
vim.keymap.set('n', 'g§', function()
    vim.fn.setreg('/', vim.fn.expand('<cword>'))
    vim.opt.hlsearch = true
end)

-- Define a local Lua function to open a scratch buffer
local function open_scratch_buffer()
    -- Create a new buffer with 'enew'
    vim.cmd('enew')
    -- Apply the necessary settings to make it a scratch buffer
    vim.bo[0].buftype = 'nofile'
    vim.bo[0].bufhidden = 'hide'
    vim.bo[0].swapfile = false
end

-- Create a command 'Scratch' that calls the above function
vim.api.nvim_create_user_command('Scratch', open_scratch_buffer, {})
vim.keymap.set('n', '<space>s', open_scratch_buffer)

-- Configure netrw module
vim.g.netrw_liststyle = 0       -- Display one entry per line (and no tree)
vim.g.netrw_altv = 1            -- Split to the right
vim.g.netrw_winsize = 25        -- Width of explorer window
vim.g.netrw_preview = 1         -- Preview window in vertical split
vim.g.netrw_alto = 0            -- Preview window in top split
vim.g.netrw_fastbrowse = 0      -- Always obtain fresh directory listings


----------------
-- Whitespace --
----------------

local indent = 4

-- General settings
vim.o.shiftwidth = indent
vim.o.tabstop = indent
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.showbreak = "╎ "
vim.o.expandtab = true

-- Enable list mode to display whitespace characters
vim.o.list = true

-- Function to generate leadmultispace pattern
local function generate_leadmultispace_pattern(length)
    local pattern = '│'
    for _ = 2, length do
        pattern = pattern .. ' '
    end
    return pattern
end

-- Configure listchars to display various invisible characters
vim.opt.listchars = {
    eol = '¬',              -- Character to show at the end of each line
    tab = '⇥ ',             -- Characters to show for a tab
    -- space = '·',            -- Character to show for a space
    trail = '᰽',            -- Character to show for trailing spaces
    extends = '┊',          -- Character to show when a line continues beyond the screen
    precedes = '┊',         -- Character to show when a line continues before the screen
    nbsp = '␣',             -- Character to show for non-breaking spaces
    -- lead = '·',             -- Character to show for leading spaces
    leadmultispace = generate_leadmultispace_pattern(indent)
}

-- -- Update the listchars if tabstop changes
-- vim.api.nvim_create_autocmd({"OptionSet"}, {
--     pattern = {"tabstop"},
--     callback = function()
--         vim.o.shiftwidth = vim.o.tabstop
--         vim.opt.listchars:append({
--             leadmultispace = generate_leadmultispace_pattern(vim.o.tabstop)
--         })
--     end
-- })


-------------------------------
-- Custom configuration paths --
-------------------------------

package.path = vim.fn.stdpath('config') .. "/lua/?.lua;" .. package.path

require('config.statusline')
require('config.lsp')
require('config.formatter')
require('config.treesitter')
require('config.telescope')
