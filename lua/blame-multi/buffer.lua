local utils = require('blame-multi.utils')
local config = require('blame-multi.config')
local Log = require('blame-multi.logger')

local M = {}

local ns = vim.api.nvim_create_namespace('BlameMultiVirtualText')
vim.cmd([[
  highlight link CommentHl Comment
]])

---Format blame data for a single line for displaying as virtual text
--- Author, date time • commit short hash • commit message
---@param line_data table<string, string>
---@return string[][]
local function format_blame_line(line_data)
    local date = { os.date("%d/%m/%Y %H:%M:%S", tonumber(line_data['author-time'])), "CommentHl" }

    if utils.git.is_committed(line_data) then
        return {
            -- TODO: strip line for author
            -- TODO: replace "MatteoBouvier" by "You"
            { line_data.author or "Unknown", "CommentHl" },
            { ", ",                          "CommentHl" },
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
---@param blame_data table<integer, table<string, string>>
M.display = function(blame_data)
    for i, line_data in pairs(blame_data) do
        vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
            virt_text = format_blame_line(line_data),
            virt_text_win_col = config.opts.virtual_text_column,
            virt_text_hide = false,
        })
    end
end

return M
