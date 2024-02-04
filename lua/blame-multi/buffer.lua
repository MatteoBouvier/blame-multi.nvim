local utils = require('blame-multi.utils')
local config = require('blame-multi.config')

local ns = vim.api.nvim_create_namespace('BlameMultiVirtualText')
vim.cmd([[
  highlight link CommentHl Comment
]])

local M = {}
local virttext_ids = {}

M.is_showing = function()
    return #virttext_ids > 0
end


local function get_column()
    if config.opts.virtual_text_column == 'colorcolumn' then
        return tonumber(vim.o.colorcolumn) - 1
    else
        return tonumber(config.opts.virtual_text_column)
    end
end


---Format blame data for each line
---@param blame_data blame_data
M.show_blame = function(blame_data)
    local column = get_column()

    local previous_line_commit = ''
    local previous_line_summary
    local header_len = 0
    local id

    for i, line_data in ipairs(blame_data) do
        if line_data.commit ~= previous_line_commit then
            previous_line_commit = line_data.commit

            local author = line_data.author or "Unknown"
            if author == utils.git.user_name() then
                author = "You"
            end

            header_len = #author + 34

            local date = os.date("%d/%m/%Y %H:%M:%S", tonumber(line_data['author-time']))

            local virt_lines = {}
            if blame_data[i + 1] and blame_data[i + 1].commit == line_data.commit then
                previous_line_summary = line_data.summary
            else
                virt_lines = { {
                    { string.rep(' ', column) .. '│ ' .. line_data.summary, 'CommentHl' }
                } }
            end

            id = vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
                virt_text = {
                    { "╭─ ", "CommentHl" },
                    { author, "CommentHl" },
                    { ", " .. date .. " • " .. line_data.commit:sub(1, 8), "CommentHl" }
                },
                virt_text_win_col = column,
                virt_text_hide = false,
                virt_lines = virt_lines,
            })
        else
            local text
            if previous_line_summary ~= nil then
                text = '│ ' .. previous_line_summary
                previous_line_summary = nil
            else
                text = '│' .. string.rep(' ', header_len)
            end

            id = vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
                virt_text = { { text, 'CommentHl' } },
                virt_text_win_col = column,
                virt_text_hide = false,
            })
        end

        table.insert(virttext_ids, id)
    end
end


---Clear blame data
M.clear_blame = function()
    for _, id in ipairs(virttext_ids) do
        vim.api.nvim_buf_del_extmark(0, ns, id)
    end

    virttext_ids = {}
end


return M
