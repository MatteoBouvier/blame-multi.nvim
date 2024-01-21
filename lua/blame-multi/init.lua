local Log = require('blame-multi.logger')
local utils = require('blame-multi.utils')
local DefaultTable = require('blame-multi.default_table')

---@alias blame_data table<int, table<string, string>>

local M = {}

---Parse git blame data for a single line
---@param line_data table<string, string>
local function parse_line_blame(line_data)
    local dt = DefaultTable:new('?')

    dt.commit = utils.string.split(line_data[1], ' ')[1]

    for i = 2, #line_data do
        local k, v = utils.string.split_at_char(line_data[i], ' ')
        dt[k] = v
    end

    return dt
end

---Parse git blame output into table
---@param line_blames string
---@return blame_data
local function parse_file_blame(line_blames)
    local lines = utils.table.slice(utils.string.split(line_blames, '\n'), 1, -2)
    local first_line_start = string.sub(lines[1], 1, 7)

    if first_line_start == "fatal: " or first_line_start == "usage :" then
        Log:trace('Error: ' .. lines[1])
        return {}
    end

    if #lines % 12 ~= 0 then
        Log:trace('Error: incorrect number of lines (' .. #lines .. ')')
        return {}
    end

    local parsed_lines = {}

    for i = 1, #lines / 12 do
        parsed_lines[i] = parse_line_blame(utils.table.slice(lines, (i - 1) * 12, i * 12))
    end

    return parsed_lines
end

---Get git blame data for each line in a file
---@return blame_data
local function get_file_blame()
    local file_name = vim.fn.expand('%:p')

    local cmd = "git --no-pager blame --line-porcelain " .. file_name
    Log:trace("git cmd: ", cmd)

    local handle = io.popen(cmd .. ' 2>&1')
    if handle == nil then return {} end

    local line_blames = handle:read('*a')
    handle:close()

    return parse_file_blame(line_blames)
end

M.blame_file = function()
    local blame = get_file_blame()
    Log:trace("parsed lines: ", blame[1])
end

return M
