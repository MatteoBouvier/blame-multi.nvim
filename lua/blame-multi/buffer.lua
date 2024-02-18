local utils = require('blame-multi.utils')
local config = require('blame-multi.config')
local colors = require('blame-multi.colors')

local M = {}

---@type {integer: BlameData}
M.blames = {}

---Save blame data for the current buffer
---@param bufnr integer
---@param blame_data BlameData
M.attach = function(bufnr, blame_data)
	M.blames[bufnr] = blame_data
end

---Delete blame data for a buffer
---@param bufnr integer
M.detach = function(bufnr)
	M.blames[bufnr] = nil
end

---Check whether blame info is being displayed in the current buffer
---@return boolean
M.is_showing = function()
	local bufnr = vim.api.nvim_get_current_buf()

	return M.blames[bufnr] ~= nil
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


local function get_header_virtual_lines(blame_info, highlights)
	if blame_info.nb_lines > 1 then
		return {}
	end

	return { {
		{ string.rep(' ', config.get_column()) .. '┃  ', highlights.bar },
		{ blame_info.data.summary, highlights.line },
	} }
end


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


---Get highlights for blame info details
---@param delta number
---@param author string
---@param surrounds_cursor_row boolean
---@return {bar: string, line: string, author: string}
M.get_highlights = function(delta, author, surrounds_cursor_row)
	return {
		bar = colors.get_highlight(config.opts['color_palette'], delta),
		line = surrounds_cursor_row and colors.StandoutVirtTextHighlight or colors.NormalVirtTextHighlight,
		author = colors.get_color_highlight(utils.string.hash(author, #colors.colors)),
	}
end


---Display a blame info
---@param blame_info BlameInfo
---@param bufnr integer
---@param ns integer
---@param author string
---@param date string|osdate
---@param highlights {bar: string, line: string, author: string}
M.display_info = function(blame_info, bufnr, ns, author, date, highlights)
	local ids = {}

	table.insert(ids, vim.api.nvim_buf_set_extmark(bufnr, ns, blame_info.line, 0, {
		virt_text = {
			{ "╭─ ", highlights.bar },
			{ author, highlights.author },
			{ ", " .. date .. " • " .. blame_info.commit:sub(1, 8), highlights.line }
		},
		virt_text_win_col = config.get_column(),
		virt_text_hide = false,
		virt_lines = get_header_virtual_lines(blame_info, highlights),
	}))

	for line_offset, virtual_text in iter_body_virtual_lines(blame_info, highlights) do
		table.insert(ids, vim.api.nvim_buf_set_extmark(bufnr, ns, blame_info.line + line_offset, 0, {
			virt_text = virtual_text,
			virt_text_win_col = config.get_column(),
			virt_text_hide = false,
		}))
	end

	blame_info.ids = ids
end


---Get blame info details to be displayed
---@param blame_data BlameData
---@param blame_info BlameInfo
---@return string
---@return string|osdate
---@return number
M.get_details = function(blame_data, blame_info)
	local author = get_author_name(blame_info)
	local date = os.date("%d/%m/%Y %H:%M:%S", tonumber(blame_info.data['author-time']))
	local delta = blame_data:time_delta(blame_info.data['author-time'])

	return author, date, delta
end


---Format blame data for each line
---@param blame_data BlameData
M.show_blame = function(blame_data)
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1

	colors.generate_standout_virt_text_highlight()

	for blame_info in blame_data:iter() do
		local author, date, delta = M.get_details(blame_data, blame_info)

		local highlights = M.get_highlights(delta, author, blame_info:surrounds_line(cursor_row))
		local ns = blame_info:surrounds_line(cursor_row) and utils.ns.standout or utils.ns.normal

		M.display_info(blame_info, bufnr, ns, author, date, highlights)
	end

	M.attach(bufnr, blame_data)
end


---Clear blame data
M.clear_blame = function()
	local bufnr = vim.api.nvim_get_current_buf()

	for _, ns in pairs(utils.ns) do
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})) do
			local id, _, _ = unpack(mark)
			vim.api.nvim_buf_del_extmark(bufnr, ns, id)
		end
	end

	M.detach(bufnr)
end


return M
