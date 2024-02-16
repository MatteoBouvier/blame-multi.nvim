local M = {}

---@class BlameInfo
---@field data {string: string}
---@field commit string
---@field line number
---@field nb_lines number
M.BlameInfo = {}

---Get new BlameInfo
---@param commit string
---@return BlameInfo
function M.BlameInfo:new(commit)
	self.__index = self
	return setmetatable({
		data = {},
		commit = commit,
		line = 0,
		nb_lines = 0,
	}, self)
end

---Set line number for line targetted by this blame info
---This will increase the count of consecutive targetted lines
---@param line number
function M.BlameInfo:set_line(line)
	if self.line == 0 then
		self.line = line - 1 -- -1 offset because line numbering starts at 0 in the vim.api
	end

	self.nb_lines = self.nb_lines + 1
end

---Check if this blame info surronds a given line number
---@param line integer
---@return boolean
function M.BlameInfo:surrounds_line(line)
	return line >= self.line and line < self.line + self.nb_lines
end

---Set data for this blame info as a key:value pair
---@param key string
---@param value string
function M.BlameInfo:set_data(key, value)
	if self.data[key] == nil then
		self.data[key] = value
	end
end

---------------------------------------------------------------------------------------------------
---@class BlameData
---@field info BlameInfo[]
---@field oldest_commit number
---@field most_recent_commit number
M.BlameData = {}

---Get a new BlameData collection
---@return BlameData
function M.BlameData:new()
	self.__index = function(instance, key)
		if type(key) == 'number' then
			return instance.data[key]
		else
			return M.BlameData[key]
		end
	end
	return setmetatable({
		info = {},
		oldest_commit = math.huge,
		most_recent_commit = 0,
	}, self)
end

---Append blame info for new line
---@param info BlameInfo
function M.BlameData:append(info)
	if self.info[#self.info] ~= info then
		table.insert(self.info, info)

		local info_timestamp = tonumber(info.data['author-time']) or math.huge

		if info_timestamp < self.oldest_commit then self.oldest_commit = info_timestamp end
		if info_timestamp > self.most_recent_commit then self.most_recent_commit = info_timestamp end
	end
end

---Determine how old a commit's timestamp is
---Returns a number in [0-1], 0 = most recent, 1 = oldest
---@param timestamp number
---@return number
function M.BlameData:time_delta(timestamp)
	if self.oldest_commit == self.most_recent_commit then return 1 end

	return (timestamp - self.oldest_commit) / (self.most_recent_commit - self.oldest_commit)
end

---Iterate through blame info objects
---@return function(): BlameInfo
function M.BlameData:iter()
	local i = 0
	return function()
		i = i + 1
		if i <= #self.info then
			return self.info[i]
		end
	end
end

return M
