local Log = require('blame-multi.logger')
local utils = require('blame-multi.utils')
local buf = require('blame-multi.buffer')

---@alias blame_data table<integer, table<string, string>>

local M = {}

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

    local parsed_lines = {}
    local parsing_new_line = true
    local dt

    for _, line in ipairs(lines) do
        line = utils.string.rtrim(line)

        if parsing_new_line then
            dt = { commit = utils.string.split(line, ' ')[1] }
            parsing_new_line = false
        elseif line:sub(1, 1) == "\t" then
            dt['line'] = line:sub(2, #line)
            table.insert(parsed_lines, dt)
            parsing_new_line = true
        else
            local k, v = utils.string.split_at_char(line, ' ')
            dt[k] = v
        end
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
    Log:trace(blame[#blame - 1])
    Log:trace(blame[#blame])
    vim.print(vim.api.nvim_get_current_buf())
    buf.display(blame)
end

return M
