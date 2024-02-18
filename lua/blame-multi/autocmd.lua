local utils = require('blame-multi.utils')
local buffer = require('blame-multi.buffer')

local M = {}

local augrp = vim.api.nvim_create_augroup("blame_multi_highlight_cursor_line", {})

M.set_autocmd = function()
	-- highlight blame data of line under cursor
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1

			local blame_data = buffer.blames[bufnr]
			local blame_info_under_cursor = blame_data[cursor_row + 1]
			local _, standout_row, _ = unpack(vim.api.nvim_buf_get_extmarks(bufnr, utils.ns.standout, 0, -1,
				{ limit = 1 })[1])
			local blame_info_standout = blame_data[standout_row + 1]

			-- IF extmark under cursor is not already standout :
			if blame_info_under_cursor == blame_info_standout then return end

			-- update standout extmark to regular highlight
			for _, standout_id in pairs(blame_info_standout.ids) do
				vim.api.nvim_buf_del_extmark(bufnr, utils.ns.standout, standout_id)
			end
			local author, date, delta = buffer.get_details(blame_data, blame_info_standout)
			local highlights = buffer.get_highlights(delta, author, false)

			buffer.display_info(blame_info_standout, bufnr, utils.ns.normal, author, date, highlights)

			-- update extmark under cursor to standout highlight
			for _, under_cursor_id in pairs(blame_info_under_cursor.ids) do
				vim.api.nvim_buf_del_extmark(bufnr, utils.ns.normal, under_cursor_id)
			end
			author, date, delta = buffer.get_details(blame_data, blame_info_under_cursor)
			highlights = buffer.get_highlights(delta, author, true)

			buffer.display_info(blame_info_under_cursor, bufnr, utils.ns.standout, author, date, highlights)
		end,
		buffer = 0,
		group = augrp,
	})
end

M.del_autocmd = function()
	vim.api.nvim_clear_autocmds({
		buffer = 0,
		group = augrp,
	})
end

return M
