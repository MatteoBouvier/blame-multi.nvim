local utils = require('blame-multi.utils')
local colors = require('blame-multi.colors')

local M = {}

local defaults = {
	-- relative_time: bool
	-- template: '<committer>, <committer-time> • <summary>'
	-- date_format: '%d/%m/%y %H:%M'
	-- max_file_length: 40000 (if auto_show)
	-- position = 'virtual', -- left | right | virtual
	-- `virtual_text_column` (only valid when `position` is 'virtual') :
	--      - a colum number where to show the virtual text
	--      - the string 'colorcolumn' to show the virtual text after the colorcolumn
	virtual_text_column = 'colorcolumn',
	-- ignore white space: bool
	color_palette = 'purple_blue', -- blues | greens | purples | reds
	-- people_icons = {
	--     You = '🐱'
	-- }
}

-- TODO: feature -> command to display current file back in previous commit from blame info
-- TODO: feature -> list in telescope (or diff view ?) all files modified in same commit as where cursor is
-- TODO: feature -> show diff with previous commit in virtual text above (prev commit info + line changes) (and keep going back ?)
-- TODO: feature -> position in window left to current, with auto scroll
-- TODO: handle folded segments

local function validate_config(opts, name, accepted_functions)
	local value = opts[name]

	for _, accepted in ipairs(accepted_functions) do
		if accepted(value) then
			return
		end
	end

	error('BlameMulti: Invalid value "' .. value .. '" for config option ' .. name)
end

function M.setup(opts)
	if vim.fn.executable('git') == 0 then
		error('BlameMulti: could not find git in path.')
	end

	M._enabled = utils.git.is_repo()

	M.opts = vim.tbl_deep_extend('force', {}, defaults, opts or {})

	validate_config(M.opts, 'virtual_text_column', {
		function(value) return value == 'colorcolumn' end,
		function(value) return type(value) == 'number' end
	})

	validate_config(M.opts, 'color_palette', {
		function(value) return colors.palettes[value] ~= nil end
	})
end

---
M.get_column = function()
	if M.opts.virtual_text_column == 'colorcolumn' then
		return tonumber(vim.o.colorcolumn) - 1
	else
		return tonumber(config.opts.virtual_text_column)
	end
end


return M
