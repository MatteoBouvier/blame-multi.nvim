vim.opt.rtp:append('/home/mbouvier/git/blame-multi.nvim')

vim.api.nvim_create_user_command("DevClear", function(opts)
    package.loaded['blame-multi'] = nil
    require('blame-multi.logger'):clear()
end, {})

vim.api.nvim_create_user_command("DevBlame", function(opts)
    package.loaded['blame-multi'] = nil
    require('blame-multi').blame_file()
end, {})

vim.api.nvim_create_user_command("DevLog", function(opts)
    package.loaded['blame-multi'] = nil
    require('blame-multi.logger'):show()
end, {})
