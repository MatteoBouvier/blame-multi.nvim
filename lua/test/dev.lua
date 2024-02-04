vim.opt.rtp:append('/home/mbouvier/git/blame-multi.nvim')

local function reload()
    package.loaded['blame-multi'] = nil
    package.loaded['blame-multi.blame'] = nil
    package.loaded['blame-multi.buffer'] = nil
    package.loaded['blame-multi.config'] = nil
    package.loaded['blame-multi.utils'] = nil

    require('blame-multi').setup()
end

vim.api.nvim_create_user_command("DevBlameToggle", function(opts)
    reload()
    require('blame-multi').toggle_blame()
end, {})

vim.api.nvim_create_user_command("DevLogClear", function(opts)
    reload()
    require('blame-multi.logger'):clear()
end, {})

vim.api.nvim_create_user_command("DevLog", function(opts)
    reload()
    require('blame-multi.logger'):show()
end, {})
