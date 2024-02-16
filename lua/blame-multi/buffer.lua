local utils = require('blame-multi.utils')
local config = require('blame-multi.config')
local colors = require('blame-multi.colors')

local M = {}

M.is_showing = function()
	if #vim.api.nvim_buf_get_extmarks(0, utils.ns.normal, 0, -1, { limit = 1 }) > 0 then
		return true
	elseif #vim.api.nvim_buf_get_extmarks(0, utils.ns.standout, 0, -1, { limit = 1 }) > 0 then
		return true
	end

	return false
end


local function get_column()
	if config.opts.virtual_text_column == 'colorcolumn' then
		return tonumber(vim.o.colorcolumn) - 1
	else
		return tonumber(config.opts.virtual_text_column)
	end
end


---Get commit author name and highlight
---@param blame_info BlameInfo
---@return string
local function get_author_name(blame_info)
	local author = blame_info.data['author'] or "Unknown"

	if author == utils.git.user_name() then
		author = "You"
	end

	return author
end


-- ---Get extra virtual lines to show below blame header (in case the blame concerns only 1 line)
-- ---@param this_line_data table<string, string>
-- ---@param next_line_data table<string, string>
-- ---@param highlights {bar: string, line: string, author: string}
-- ---@return string[][]
-- ---@return string?
-- local function get_virtual_lines(this_line_data, next_line_data, highlights)
-- 	if next_line_data and next_line_data.commit == this_line_data.commit then
-- 		return {}, this_line_data.summary
-- 	else
-- 		return { {
-- 			{ string.rep(' ', get_column()) .. '┃  ', highlights.bar },
-- 			{ this_line_data.summary, highlights.line }
-- 		} }, nil
-- 	end
-- end
local function get_header_virtual_lines(blame_info, highlights)
	if blame_info.nb_lines > 1 then
		return {}
	end

	return { {
		{ string.rep(' ', get_column()) .. '┃  ', highlights.bar },
		{ blame_info.data.summary, highlights.line },
	} }
end

-- 		-- new line in same commit
-- 	else
-- 		local text
-- 		if previous_line_summary ~= nil then
-- 			text = '  ' .. previous_line_summary
-- 			previous_line_summary = nil
-- 		else
-- 			text = string.rep(' ', header_len)
-- 		end
--
-- 		vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
-- 			virt_text = {
-- 				{ '┃', highlights.bar },
-- 				{ text, highlights.line } },
-- 			virt_text_win_col = column,
-- 			virt_text_hide = false,
-- 		})
-- 	end
-- end
local function iter_body_virtual_lines(blame_info, highlights)
	local i = 0
	return function()
		i = i + 1

		if i >= blame_info.nb_lines then return end

		local text
		if i == 1 then
			text = '  ' .. blame_info.data.summary
		else
			text = string.rep(' ', #blame_info.data.summary + 2)
		end

		return i, {
			{ '┃', highlights.bar },
			{ text, highlights.line },
		}
	end
end


local function get_highlights(delta, surrounds_cursor_row, author)
	return {
		bar = colors.get_highlight(config.opts['color_palette'], delta),
		line = surrounds_cursor_row and colors.StandoutVirtTextHighlight or colors.NormalVirtTextHighlight,
		author = colors.get_color_highlight(utils.string.hash(author, #colors.colors)),
	}
end


---Format blame data for each line
---@param blame_data BlameData
M.show_blame = function(blame_data)
	local column = get_column()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]

	colors.generate_standout_virt_text_highlight()

	for blame_info in blame_data:iter() do
		local delta = blame_data:time_delta(blame_info.data['author-time'])
		local author = get_author_name(blame_info)
		local date = os.date("%d/%m/%Y %H:%M:%S", tonumber(blame_info.data['author-time']))

		local highlights = get_highlights(delta, blame_info:surrounds_line(cursor_row), author)
		local ns = blame_info:surrounds_line(cursor_row) and utils.ns.standout or utils.ns.normal

		vim.api.nvim_buf_set_extmark(0, ns, blame_info.line, 0, {
			virt_text = {
				{ "╭─ ", highlights.bar },
				{ author, highlights.author },
				{ ", " .. date .. " • " .. blame_info.commit:sub(1, 8), highlights.line }
			},
			virt_text_win_col = column,
			virt_text_hide = false,
			virt_lines = get_header_virtual_lines(blame_info, highlights),
		})

		for line_offset, virtual_text in iter_body_virtual_lines(blame_info, highlights) do
			vim.api.nvim_buf_set_extmark(0, ns, blame_info.line + line_offset, 0, {
				virt_text = virtual_text,
				virt_text_win_col = column,
				virt_text_hide = false,
			})
		end
	end
end


---Clear blame data
M.clear_blame = function()
	for _, ns in pairs(utils.ns) do
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})) do
			local id, _, _ = unpack(mark)
			vim.api.nvim_buf_del_extmark(0, ns, id)
		end
	end
end


return M
