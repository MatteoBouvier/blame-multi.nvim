local function Hex2Dec(color)
    local r = tonumber(color:sub(1, 2), 16)
    local g = tonumber(color:sub(3, 4), 16)
    local b = tonumber(color:sub(5, 6), 16)
    return { r = r, g = g, b = b }
end

local function Dec2Hex(color)
    local r = string.format("%06x", color.r):sub(5, 6)
    local g = string.format("%06x", color.g):sub(5, 6)
    local b = string.format("%06x", color.b):sub(5, 6)
    return r .. g .. b
end

local M = {}

M.palettes = {}

M.register_palette = function(name, palette)
    local p = {}
    for i, color in ipairs(palette) do
        local hl_name = 'Color_' .. name .. tostring(i)
        vim.api.nvim_set_hl(0, hl_name, { fg = color, bold = true })
        table.insert(p, { color, hl_name })
    end

    M.palettes[name] = p
end

M.register_palette('blues', { "#011F4B", "#03396C", "#005B96", "#6497B1", "#B3CDE0" })
M.register_palette('greens', { "#1A302B", "#315C3E", "#4C8355", "#A2B387", "#DFD7CE" })
M.register_palette('purples', { "#3F1651", "#653780", "#9C3587", "#E53F71", "#F89F5B" })
M.register_palette('reds', { "#E7331A", "#F17B16", "#F89A23", "#FFC82F", "#F6FF92" })
M.register_palette('red_green', { "#11502C", "#15703D", "#F8B52B", "#EC4A33", "#BE272A" })
M.register_palette('purple_blue', { "#541675", "#7E38B7", "#9C89FF", "#99CCED", "#C4FEFF" })


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


M.colors = {
    "LightCyan", "LightBlue", "LightCyan3", "LightBlue4", "SlateGray1", "SlateGray3", "OldLace", "gainsboro",
    "lavender", "pink", "RosyBrown", "plum4,", "thistle1", "thistle", "LemonChiffon", "wheat", "MistyRose3,",
    "MistyRose", "LightGray", "cornsilk3", "wheat3", "burlywood3", "burlywood1", "LavenderBlush3", "LavenderBlush4",
    "burlywood4", "LightCyan4", "khaki", "khaki4", "DarkKhaki", "gold3", "gold", "goldenrod1", "goldenrod3",
    "goldenrod4", "salmon1", "coral", "tan1", "peru", "sienna1", "sienna3", "salmon3", "LightSalmon3,", "chocolate1,",
    "DarkOrange", "chocolate", "coral3", "coral4", "tan4", "yellow", "yellow3", "LawnGreen", "chartreuse3", "green1,",
    "DarkOliveGreen1", "PaleGreen", "SeaGreen1", "SeaGreen3", "PaleGreen3", "OliveDrab3", "MediumSeaGreen,",
    "LimeGreen", "MediumAquamarine", "DarkSeaGreen1,", "DarkSeaGreen", "DarkSeaGreen4", "green3", "ForestGreen",
    "DarkGreen", "SeaGreen", "PaleGreen4", "OliveDrab", "DarkOliveGreen", "DarkSlateGray", "plum1", "plum3", "violet",
    "MediumOrchid", "DarkViolet", "purple4", "HotPink", "PaleVioletRed1", "IndianRed1,", "IndianRed,", "LightCoral",
    "IndianRed4", "LightPink", "LightPink3", "LightPink4", "orchid4", "purple1", "MediumPurple1", "MediumPurple",
    "MediumPurple4", "SlateBlue", "SlateBlue1", "SlateBlue4,", "tomato", "red", "red4", "magenta", "VioletRed,",
    "HotPink3", "HotPink4", "cyan", "cyan3", "PowderBlue", "PaleTurquoise3", "aquamarine4", "CadetBlue4", "aquamarine",
    "aquamarine3", "LightSeaGreen", "MediumTurquoise", "CadetBlue1", "CadetBlue3", "cyan4", "DarkSlateBlue",
    "DeepSkyBlue", "DeepSkyBlue3", "DeepSkyBlue4", "LightSkyBlue", "LightSkyBlue1,", "LightSkyBlue3", "blue", "navy",
    "RoyalBlue1", "RoyalBlue4", "DodgerBlue", "DodgerBlue3", "SteelBlue3", "SkyBlue", "SteelBlue1", "SkyBlue3",
    "DodgerBlue4", "SkyBlue4"
}

local color_highlights = {}

---Get a color highlight from an index
---@param index number
---@return string
M.get_color_highlight = function(index)
    index = index % #M.colors + 1
    local color = M.colors[index]
    local hl_name = 'BlameMulti_' .. color

    if not vim.tbl_contains(color_highlights, color) then
        vim.api.nvim_set_hl(0, hl_name, { fg = color, bold = true })
        color_highlights[color] = hl_name
    end
    return hl_name
end

M.get_background_color = function()
    return Hex2Dec(string.format("%06x", vim.api.nvim_get_hl(0, { name = 'Normal' }).bg))
end

-- adapted from https://stackoverflow.com/a/65233542
---Blend two colors based on transparency
---@param front_color RGBA_color
---@param back_color RGB_color
---@return RGB_color
M.blend_colors = function(front_color, back_color)
    local combined_color = {
        r = ((1 - front_color.a) * back_color.r) + (front_color.a * front_color.r),
        g = ((1 - front_color.a) * back_color.g) + (front_color.a * front_color.g),
        b = ((1 - front_color.a) * back_color.b) + (front_color.a * front_color.b)
    }

    combined_color.r = combined_color.r > 255 and 255 or combined_color.r
    combined_color.g = combined_color.g > 255 and 255 or combined_color.g
    combined_color.b = combined_color.b > 255 and 255 or combined_color.b

    return combined_color
end


vim.api.nvim_set_hl(0, 'BlameMultiVirtTextNormal_Highlight', { fg = "#6e6a86" })
M.NormalVirtTextHighlight = 'BlameMultiVirtTextNormal_Highlight'

M.generate_standout_virt_text_highlight = function()
    local front_color = { r = 255, g = 255, b = 255, a = 0.1 }
    local background_color = M.get_background_color()
    local combined_color = M.blend_colors(front_color, background_color)

    vim.api.nvim_set_hl(0, 'BlameMultiVirtTextStandout_Highlight', { bg = "#" .. Dec2Hex(combined_color) })
end
M.StandoutVirtTextHighlight = 'BlameMultiVirtTextStandout_Highlight'

return M
