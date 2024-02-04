local blame = require('blame-multi.blame')
local buffer = require('blame-multi.buffer')
local config = require('blame-multi.config')
local Log = require('blame-multi.logger')

local M = {}

M.setup = function(opts)
    opts = opts or {}
    config.setup(opts)
end

M.setup()


if config._enabled then
    M.show_blame = function()
        local blame_data = blame.get_file_blame()
        Log:trace("parsed lines: ", blame[1])
        Log:trace(blame[#blame - 1])
        Log:trace(blame[#blame])
        buffer.show_blame(blame_data)
    end

    M.clear_blame = buffer.clear_blame

    M.toggle_blame = function()
        if buffer.is_showing() then
            M.clear_blame()
        else
            M.show_blame()
        end
    end

    -- user commands
    vim.api.nvim_create_user_command('BlameShow', function(_)
        M.show_blame()
    end, {})

    vim.api.nvim_create_user_command('BlameClear', function(_)
        M.clear_blame()
    end, {})

    vim.api.nvim_create_user_command('BlameToggle', function(_)
        M.toggle_blame()
    end, {})
end


return M
