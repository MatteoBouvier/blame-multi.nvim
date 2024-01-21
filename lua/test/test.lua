local utils = require('blame-multi.utils')

---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
---@param ignore_mt boolean True to ignore metatables (a recursive function to tests tables inside tables)
function table_equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or table_equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function test_table_slice()
    assert(table_equals(utils.table.slice({ 1, 2, 3, 4, 5 }, 2, 4), { 2, 3, 4 }, true))
end

test_table_slice()
print('END')
