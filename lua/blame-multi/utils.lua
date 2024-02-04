local M = {
    string = {},
    table = {},
    git = {},
}

---Split string at every occurence of <delimiter>
---@param s string
---@param delimiter string
---@return string[]
M.string.split = function(s, delimiter)
    local result = {};

    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end

    return result
end

---Split a string in two at first occurence of a character
---@param s string
---@param char string
---@return string
---@return string
M.string.split_at_char = function(s, char)
    local index_of_char = s:find(char)

    if index_of_char == nil then
        return s, ''
    end

    return s:sub(1, index_of_char - 1), s:sub(index_of_char + 1, #s)
end

---Subset the first <n> lines from a string
---@param s string
---@param n integer
---@return string
M.string.first_n_lines = function(s, n)
    local lines = M.string.split(s, '\n')
    return table.concat(lines, '\n', 1, n)
end

---Trim trailing spaces
---@param s any
---@return string
M.string.rtrim = function(s)
    return string.gsub(s, "(.-)[ ]*$", "%1")
end

---Get slice of table t
---@param t table
---@param start integer
---@param stop integer
---@return table
M.table.slice = function(t, start, stop)
    local slice = {}

    if start < 0 then start = #t + start + 1 end
    if stop < 0 then stop = #t + stop + 1 end

    for i = start or 1, stop or #t do
        table.insert(slice, t[i])
    end

    return slice
end

---Get keys of table t
---@param t table
---@return table
M.table.keys = function(t)
    local keyset = {}
    for k, _ in pairs(t) do
        table.insert(keyset, k)
    end
    return keyset
end

---Get number of elements in any table
---@param t table
---@return integer
M.table.length = function(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

---Check if a line has been committed
---@param t table
---@return boolean
M.git.is_committed = function(t)
    if t.commit == nil then return false end
    return t.commit ~= "0000000000000000000000000000000000000000"
end

M.git.is_repo = function()
    return vim.split(vim.api.nvim_command_output [[:!git rev-parse --is-inside-work-tree]], '\n')[3] == 'true'
end

M.git.user_name = function()
    return vim.split(vim.api.nvim_command_output [[:!git config --get user.name]], "\n")[3]
end

return M
