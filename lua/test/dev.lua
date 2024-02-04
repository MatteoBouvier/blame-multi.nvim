vim.opt.rtp:append('/home/mbouvier/git/blame-multi.nvim')

vim.api.nvim_create_user_command("DevReload", function(opts)
    package.loaded['blame-multi'] = nil
    package.loaded['blame-multi.blame'] = nil
    package.loaded['blame-multi.buffer'] = nil
    package.loaded['blame-multi.config'] = nil
    package.loaded['blame-multi.utils'] = nil

    require('blame-multi').setup()
end, {})

vim.api.nvim_create_user_command("DevLogClear", function(opts)
    require('blame-multi.logger'):clear()
end, {})

vim.api.nvim_create_user_command("DevLog", function(opts)
    require('blame-multi.logger'):show()
end, {})
