local utils = require('blame-multi.utils')

local M = {}

local defaults = {
    -- highlight:  highlight BlameMultiVirtualText guifg=lightgrey
    -- relative_time: bool
    -- template: '<committer>, <committer-time> • <summary>'
    -- date_format: '%d/%m/%y %H:%M'
    -- auto_show: bool
    -- delay: 500 (if auto_show)
    -- max_file_length: 40000 (if auto_show)
    position = 'virtual', -- left | right | virtual

    -- `virtual_text_column` (only valid when `position` is 'virtual') :
    --      - a colum number where to show the virtual text
    --      - the string 'colorcolumn' to show the virtual text after the colorcolumn
    virtual_text_column = 'colorcolumn',
    -- ignore white space: bool
    -- color_palette
    -- people_icons = {
    --     You = '🐱'
    -- }
    -- color_by = 'people', -- people | date
}

-- TODO: feature -> list in telescope (or diff view ?) all files modified in same commit as where cursor is
-- TODO: feature -> group lines with common author and timestamp : show info only once + color vertical line
--                  if possible, show info on one line, commit message on line under
-- TODO: feature -> color lines by how old they are
-- TODO: feature -> show diff with previous commit in virtual text above (prev commit info + line changes) (and keep going back ?)
-- TODO: feature -> position in window left to current, with auto scroll
-- TODO: handle folded segments

function M.setup(opts)
    if vim.fn.executable('git') == 0 then
        print('BlameMulti: could not find git in path.')
        return
    end

    M._enabled = utils.git.is_repo()

    M.opts = vim.tbl_deep_extend('force', {}, defaults, opts or {})
end

return M
