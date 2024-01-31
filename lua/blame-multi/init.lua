local blame = require('blame-multi.blame')
local config = require('blame-multi.config')

local M = {}

M.setup = function(opts)
    opts = opts or {}
    config.setup(opts)
end

M.setup()

M.blame_file = blame.blame_file

return M
