return {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
        require('distant'):setup()

        vim.api.nvim_create_user_command('DistantConnectPrompt', function()
            vim.ui.input({ prompt = 'Username: ' }, function(username)
                if not username or username == '' then return end
                vim.ui.input({ prompt = 'Host: ' }, function(host)
                    if not host or host == '' then return end
                    local url = string.format('ssh://%s@%s', username, host)
                    vim.cmd('DistantConnect ' .. url)
                end)
            end)
        end, { desc = 'Connect to remote server with prompts' })

        vim.keymap.set('n', '<leader>dc', ':DistantConnectPrompt<CR>', { desc = 'Distant Connect' })
    end
}
