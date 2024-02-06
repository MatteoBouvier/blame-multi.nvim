local Log = require('blame-multi.logger')

local M = {}

M.palettes = {}

M.register_palette = function(name, palette)
    local p = {}
    for _, color in ipairs(palette) do
        table.insert(p, { color, '' })
    end

    M.palettes[name] = p
end

M.register_palette('blues', { "#011F4B", "#03396C", "#005B96", "#6497B1", "#B3CDE0" })
M.register_palette('greens', { "#1A302B", "#315C3E", "#4C8355", "#A2B387", "#DFD7CE" })
M.register_palette('purples', { "#3F1651", "#653780", "#9C3587", "#E53F71", "#F89F5B" })
M.register_palette('reds', { "#E7331A", "#F17B16", "#F89A23", "#FFC82F", "#F6FF92" })
M.register_palette('red_green', { "#11502C", "#15703D", "#F8B52B", "#EC4A33", "#BE272A" })
M.register_palette('purple_blue', { "#541675", "#7E38B7", "#9C89FF", "#99CCED", "#C4FEFF" })

for palette_name, palette in pairs(M.palettes) do
    for i, color in ipairs(palette) do
        local hl_name = 'Color_' .. palette_name .. tostring(i)
        vim.api.nvim_set_hl(0, hl_name, { fg = color[1], bold = true })
        palette[i][2] = hl_name
    end
end

---Get a color highlight from a palette and a value from 0 to 1
---@param palette_name string
---@param value number
---@return string
M.get_highlight = function(palette_name, value)
    local color_palette = M.palettes[palette_name]

    local int, frac = math.modf(value * (#color_palette - 1))
    local index = int + (frac > 0.5 and 1 or 0) + 1

    return color_palette[index][2]
end


return M
