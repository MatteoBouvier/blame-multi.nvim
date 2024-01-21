DefaultTable = {}

function DefaultTable:new(d)
    return setmetatable({
        __default = d
    }, self)
end

function DefaultTable:__index()
    return self.__default
end

return DefaultTable
