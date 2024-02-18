local Log = require('blame-multi.logger')
local utils = require('blame-multi.utils')
local info = require('blame-multi.info')

local M = {}

---Parse git blame output into table
---@param line_blames string
---@return BlameData
local function parse_file_blame(line_blames)
	local lines = utils.table.slice(utils.string.split(line_blames, '\n'), 1, -2)
	local first_line_start = string.sub(lines[1], 1, 7)

	if first_line_start == "fatal: " or first_line_start == "usage :" then
		Log:trace('Error: ' .. lines[1])
		return {}
	end

	local parsed_lines = info.BlameData:new()
	local parsing_new_line = true
	local line_counter = -1
	local current_commit
	---@type BlameInfo
	local blame_info

	for _, line in ipairs(lines) do
		line = utils.string.rtrim(line)

		if parsing_new_line then
			local commit = utils.string.split(line, ' ')[1]
			if commit ~= current_commit then
				blame_info = info.BlameInfo:new(commit)
				current_commit = commit
			end

			line_counter = line_counter + 1
			parsing_new_line = false
		elseif line:sub(1, 1) == "\t" then
			blame_info:set_line(line_counter)
			parsed_lines:append(blame_info)

			parsing_new_line = true
		else
			local k, v = utils.string.split_at_char(line, ' ')
			blame_info:set_data(k, v)
		end
	end

	return parsed_lines
end

---Get raw blame from git blame procelain
---@param file_name string
---@return string
local function get_raw_file_blame(file_name)
	local cmd = "git --no-pager blame --line-porcelain " .. file_name
	Log:trace("git cmd: ", cmd)

	local handle = io.popen(cmd .. ' 2>&1')
	if handle == nil then return "" end

	local line_blames = handle:read('*a')
	handle:close()

	return line_blames
end


---Get git blame data for each line in a file
---@return BlameData
M.get_file_blame = function()
	local file_name = vim.fn.expand('%:p')

	local line_blames = get_raw_file_blame(file_name)
	return parse_file_blame(line_blames)
end

return M
