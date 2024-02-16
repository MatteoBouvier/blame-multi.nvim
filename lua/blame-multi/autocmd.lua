local utils = require('blame-multi.utils')
local colors = require('blame-multi.colors')

local M = {}

local augrp = vim.api.nvim_create_augroup("blame_multi_highlight_cursor_line", {})

M.set_autocmd = function()
    return
    -- highlight blame data of line under cursor
    -- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    --     callback = function()
    --         local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    --
    --         for _, data in ipairs(vim.api.nvim_buf_get_extmarks(0, utils.ns.normal, { cursor_row, 0 }, { cursor_row, -1 }, {
    --             details = true
    --         })) do
    --             local _, row, _, details = unpack(data)
    --             local virt_text, col = details.virt_text, details.virt_text_win_col
    --
    --
    --             local front_color = { r = 255, g = 255, b = 255, a = 0.25 }
    --             local background_color = colors.get_background_color()
    --             virt_text[2][2] = colors.blend_colors(front_color, background_color)
    --
    --             vim.api.nvim_buf_set_extmark(0, utils.ns.normal, row, 0, {
    --                 virt_text = virt_text,
    --                 virt_text_win_col = col,
    --             })
    --         end
    --     end,
    --     buffer = 0,
    --     group = augrp,
    -- })
end

M.del_autocmd = function()
    vim.api.nvim_clear_autocmds({
        buffer = 0,
        group = augrp,
    })
end

return M
