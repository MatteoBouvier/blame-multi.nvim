vim.opt.rtp:append('/home/mbouvier/git/blame-multi.nvim')

local function unload()
    package.loaded['blame-multi'] = nil
    package.loaded['blame-multi.buffer'] = nil
    package.loaded['blame-multi.default_table'] = nil
    package.loaded['blame-multi.logger'] = nil
    package.loaded['blame-multi.utils'] = nil
end

vim.api.nvim_create_user_command("DevClear", function(opts)
    unload()
    require('blame-multi.logger'):clear()
end, {})

vim.api.nvim_create_user_command("DevBlame", function(opts)
    unload()
    require('blame-multi').blame_file()
end, {})

vim.api.nvim_create_user_command("DevLog", function(opts)
    unload()
    require('blame-multi.logger'):show()
end, {})

vim.api.nvim_create_user_command("DevBuffer", function(opts)
    unload()
    require('blame-multi.buffer').test()
end, {})
