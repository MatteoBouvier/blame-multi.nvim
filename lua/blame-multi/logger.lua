local utils = require('blame-multi.utils')

local Logger = {}
Logger.__index = Logger

function Logger:new()
    local instance = setmetatable({
        enabled = true,
        lines = {},
        max_lines = 50,
    }, self)
    return instance
end

function Logger:enable()
    self.enabled = true
end

function Logger:disable()
    self.enabled = false
end

function Logger:clear()
    self.lines = {}
end

function Logger:show()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self.lines)
    vim.api.nvim_win_set_buf(0, bufnr)
end

function Logger:trace(...)
    local lines = {}

    for i = 1, select("#", ...) do
        local element = select(i, ...)

        if type(element) == "table" then
            local nb_elements = utils.table.length(element)
            if nb_elements == 0 then
                table.insert(lines, "{}")
            else
                local keys = utils.table.keys(element)

                if nb_elements == 1 then
                    table.insert(lines, "{" .. keys[1] .. " = " .. element[keys[1]] .. "}")
                else
                    table.insert(lines, "{" .. keys[1] .. " = " .. element[keys[1]] .. ",")
                    for ki = 2, #keys - 1 do
                        table.insert(lines, " " .. keys[ki] .. " = " .. element[keys[ki]] .. ",")
                    end
                    table.insert(lines, " " .. keys[#keys] .. " = " .. element[keys[#keys]] .. "}")
                end
            end
        elseif type(element) == "string" then
            for _, line in ipairs(utils.string.split(element, '\n')) do
                table.insert(lines, line)
            end
        else
            table.insert(lines, tostring(element))
        end
    end

    for _, line in ipairs(lines) do
        table.insert(self.lines, line)
    end

    while #self.lines > self.max_lines do
        table.remove(self.lines, 1)
    end
end

local logger = Logger:new()

return logger
