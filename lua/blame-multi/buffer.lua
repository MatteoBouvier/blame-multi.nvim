local utils = require('blame-multi.utils')
local config = require('blame-multi.config')
local colors = require('blame-multi.colors')

local ns = vim.api.nvim_create_namespace('BlameMultiVirtualText')

local M = {}

M.is_showing = function()
    return #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0
end


local function get_column()
    if config.opts.virtual_text_column == 'colorcolumn' then
        return tonumber(vim.o.colorcolumn) - 1
    else
        return tonumber(config.opts.virtual_text_column)
    end
end


---Get commit author name and highlight
---@param line_data table<string, string>
---@return string
---@return string
local function get_author_name(line_data)
    local author = line_data.author or "Unknown"
    if author == utils.git.user_name() then
        author = "You"
    end

    local author_hl = colors.get_color_highlight(utils.string.hash(author, #colors.colors))

    return author, author_hl
end


---Get oldeset time-stamp in blame data
---@param blame_data blame_data
---@return number, number
local function get_timestamp_range(blame_data)
    local oldest = math.huge
    local most_recent = 0

    for _, line_data in ipairs(blame_data) do
        local line_timestamp = tonumber(line_data['author-time']) or math.huge

        if line_timestamp < oldest then
            oldest = line_timestamp
        end

        if line_timestamp > most_recent then
            most_recent = line_timestamp
        end
    end

    return most_recent, oldest
end


---Get position of a timestamp as a number in [0, 1] (0 = most recent, 1 = oldest)
---@param blame_data blame_data
---@return function(timestamp: number): number
local function time_delta(blame_data)
    local most_recent_timestamp, oldest_timestamp = get_timestamp_range(blame_data)

    if most_recent_timestamp == oldest_timestamp then
        return function(_)
            return 1
        end
    end

    local max = most_recent_timestamp - oldest_timestamp
    return function(timestamp)
        return (timestamp - oldest_timestamp) / max
    end
end


---Get extra virtual lines to show below blame header (in case the blame concerns only 1 line)
---@param this_line_data table<string, string>
---@param next_line_data table<string, string>
---@param hl string
---@return string[][]
---@return string?
local function get_virtual_lines(this_line_data, next_line_data, hl)
    if next_line_data and next_line_data.commit == this_line_data.commit then
        return {}, this_line_data.summary
    else
        return { {
            { string.rep(' ', get_column()) .. '┃  ', hl },
            { this_line_data.summary, 'CommentHl' }
        } }, nil
    end
end


-- TODO: add highlight for current line -> make current line blame stand out
---Format blame data for each line
---@param blame_data blame_data
M.show_blame = function(blame_data)
    local column = get_column()
    local get_time_delta = time_delta(blame_data)

    local previous_line_commit = ''
    local previous_line_summary
    local header_len = 0
    local virt_lines
    local hl = nil

    for i, line_data in ipairs(blame_data) do
        if line_data.commit ~= previous_line_commit then
            previous_line_commit = line_data.commit

            local delta = get_time_delta(line_data['author-time'])
            hl = colors.get_highlight(config.opts['color_palette'], delta)

            local author, author_hl = get_author_name(line_data)
            header_len = #author + 34

            local date = os.date("%d/%m/%Y %H:%M:%S", tonumber(line_data['author-time']))

            virt_lines, previous_line_summary = get_virtual_lines(line_data, blame_data[i + 1], hl)

            vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
                virt_text = {
                    { "╭─ ", hl },
                    { author, author_hl },
                    { ", " .. date .. " • " .. line_data.commit:sub(1, 8), "CommentHl" }
                },
                virt_text_win_col = column,
                virt_text_hide = false,
                virt_lines = virt_lines,
            })
        else
            local text
            if previous_line_summary ~= nil then
                text = '  ' .. previous_line_summary
                previous_line_summary = nil
            else
                text = string.rep(' ', header_len)
            end

            vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
                virt_text = {
                    { '┃', hl },
                    { text, 'CommentHl' } },
                virt_text_win_col = column,
                virt_text_hide = false,
            })
        end
    end
end


---Clear blame data
M.clear_blame = function()
    for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})) do
        local id, _, _ = unpack(mark)
        vim.api.nvim_buf_del_extmark(0, ns, id)
    end
end


return M
