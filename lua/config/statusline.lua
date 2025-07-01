vim.o.statusline = "%<%f  %h %m %r %w %=%y %{&fileencoding?&fileencoding:&encoding} [%{&fileformat}] %l:%c%V %p%%"

-- Function to set laststatus based on window count
local function set_laststatus()
    local win_count = #vim.api.nvim_list_wins()
    if win_count > 1 then
        vim.opt.laststatus = 3
    else
        vim.opt.laststatus = 1
    end
end

-- Create an autocommand group
vim.api.nvim_create_augroup('DynamicLastStatus', { clear = true })

-- Autocommand to trigger on events that can change the window count
vim.api.nvim_create_autocmd({ 'WinEnter', 'WinClosed', 'VimResized' }, {
    group = 'DynamicLastStatus',
    callback = set_laststatus,
})

-- Initial call to set the status line correctly on startup
set_laststatus()
