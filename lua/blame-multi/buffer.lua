local utils = require('blame-multi.utils')
local config = require('blame-multi.config')

local ns = vim.api.nvim_create_namespace('BlameMultiVirtualText')
vim.cmd([[
  highlight link CommentHl Comment
]])

local M = {}
local virttext_ids = {}

M.is_showing = function()
    vim.print(virttext_ids)
    return #virttext_ids > 0
end

---Format blame data for each line
---@param blame_data blame_data
local function get_formatted_blames(blame_data)
    local previous_line_commit = blame_data[0].commit
    local line_groups = {}
    local line_format

    for i, line_data in ipairs(blame_data) do
        if line_data.commit ~= previous_line_commit then
            previous_line_commit = line_data.commit
            line_format = {}
        else
            table.insert(line_format, '')
        end
    end
end

---Format blame data for a single line for displaying as virtual text
--- Author, date time • commit short hash • commit message
---@param line_data table<string, string>
---@return string[][]
local function format_blame_line(line_data)
    local date = { os.date("%d/%m/%Y %H:%M:%S", tonumber(line_data['author-time'])), "CommentHl" }

    if utils.git.is_committed(line_data) then
        local author = line_data.author or "Unknown"
        if author == utils.git.user_name() then
            author = "You"
        end

        return {
            { author, "CommentHl" },
            { ", ",   "CommentHl" },
            date,
            { " • ", "CommentHl" },
            { line_data.commit:sub(1, 8), "CommentHl" },
            { " • ", "CommentHl" },
            { line_data.summary, "CommentHl" },
        }
    else
        return {
            { "You", "CommentHl" },
            { ", ",  "CommentHl" },
            date,
            { " • Uncommitted changes", "CommentHl" },
        }
    end
end

---Display blame data as virtual text
---@param blame_data blame_data
M.show_blame = function(blame_data)
    local column
    if config.opts.virtual_text_column == 'colorcolumn' then
        column = vim.o.colorcolumn
    else
        column = config.opts.virtual_text_column
    end

    for i, line_data in pairs(blame_data) do
        local id = vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
            virt_text = format_blame_line(line_data),
            virt_text_win_col = column,
            virt_text_hide = false,
        })
        table.insert(virttext_ids, id)
    end

    vim.print(virttext_ids)
end

---Clear blame data
M.clear_blame = function()
    for _, id in ipairs(virttext_ids) do
        vim.api.nvim_buf_del_extmark(0, ns, id)
    end

    virttext_ids = {}
end


return M
