--=============================================================================
-- scrollbar.lua --- scrollbar for SpaceVim
-- Copyright (c) 2016-2022 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local M = {}
local config
local log = require('scrollbar.logger')
local util = require('scrollbar.util')

local function get(opt)
    return config[opt]
end

local scrollbar_bufnr = -1
local scrollbar_winid = -1
local scrollbar_size = -1

local function add_highlight(winid, size)
    if vim.api.nvim_win_is_valid(winid) then
        local highlight = get('highlight')
        local ns = vim.api.nvim_create_namespace('scrollbar.highlight')
        vim.api.nvim_buf_set_extmark(scrollbar_bufnr, ns, 0, 0, {
            end_col = 1,
            hl_group = highlight.head,
        })
        for i = 1, size - 2 do
            vim.api.nvim_buf_set_extmark(scrollbar_bufnr, ns, i, 0, {
                end_col = 1,
                hl_group = highlight.body,
            })
        end
        vim.api.nvim_buf_set_extmark(scrollbar_bufnr, ns, size - 1, 0, {
            end_col = 1,
            hl_group = highlight.tail,
        })
    end
end

local function fix_size(size)
    return math.max(get('min_size'), math.min(get('max_size'), math.floor(size + 0.5)))
end

local function gen_bar_lines(size)
    local shape = get('shape')
    local lines = { shape.head }
    for _ = 2, size - 1 do
        table.insert(lines, shape.body)
    end
    table.insert(lines, shape.tail)
    return lines
end

                       -- 1        76      43
function M.get_position(topline, total, height)
    local bar_size = fix_size(height * height / total) -- 10
    local precision = height - bar_size -- 33
    local each_line = (total - height) * 1.0 / precision -- (76 - 43)/ 33
    -- 可见区域的 topline
    local visble_line = vim.fn.min({ topline, total - height + 1 }) -- 1, 76 - 43 = 33 + 1 1
    local row
    if each_line >= 1 then
        row = vim.fn.float2nr(visble_line - 1 / each_line)
    else
        row = vim.fn.float2nr(visble_line - 1/ each_line - 1 / each_line)
    end

    row = vim.fn.float2nr(
        (visble_line - 1) / each_line
    )

    return bar_size, row
end

local function create_scrollbar_buffer(lines)
    if not vim.api.nvim_buf_is_valid(scrollbar_bufnr) then
        scrollbar_bufnr = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = scrollbar_bufnr })
    vim.api.nvim_buf_set_lines(scrollbar_bufnr, 0, -1, false, lines)
    return scrollbar_bufnr
end

function M.show()
    local saved_ei = vim.o.eventignore
    vim.o.eventignore = 'all'
    for _, ft in ipairs(get('excluded_filetypes')) do
        if ft == vim.o.filetype then
            M.clear()
            vim.o.eventignore = saved_ei
            return
        end
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    if util.is_float(winid) then
        M.clear()
        vim.o.eventignore = saved_ei
        return
    end

    local total = vim.api.nvim_buf_line_count(bufnr)
    local height = vim.api.nvim_win_get_height(winid)

    if total <= height then
        M.clear()
        vim.o.eventignore = saved_ei
        return
    end

    local width = vim.api.nvim_win_get_width(winid)
    local col = width - get('width') - get('right_offset')

    local bar_size, row = M.get_position(vim.fn.line('w0'), total, height)

    local opts = {
        style = 'minimal',
        relative = 'win',
        win = winid,
        width = get('width'),
        height = bar_size,
        row = row,
        col = vim.fn.float2nr(col),
        focusable = false,
        zindex = 10,
        border = 'none',
    }
    if config.debug then
        log.info(
            string.format(
                'winid %d, bufnr %d, bar_size %d, row %d, col %d',
                winid,
                bufnr,
                bar_size,
                row,
                col
            )
        )
    end

    if util.is_float(scrollbar_winid) then
        if bar_size ~= scrollbar_size then
            scrollbar_size = bar_size
            local bar_lines = gen_bar_lines(bar_size)
            vim.api.nvim_buf_set_lines(scrollbar_bufnr, 0, -1, false, bar_lines)
        end
        vim.api.nvim_win_set_config(scrollbar_winid, opts)
    else
        scrollbar_size = bar_size
        local bar_lines = gen_bar_lines(bar_size)
        scrollbar_bufnr = create_scrollbar_buffer(bar_lines)
        scrollbar_winid = vim.api.nvim_open_win(scrollbar_bufnr, false, opts)
    end
    add_highlight(scrollbar_winid, scrollbar_size)
    vim.o.eventignore = saved_ei
end

function M.clear()
    if vim.api.nvim_win_is_valid(scrollbar_winid) then
        vim.api.nvim_win_close(scrollbar_winid, true)
    end
end

function M.setup(opt)
    config = require('scrollbar.config').setup(opt)
    local augroup = vim.api.nvim_create_augroup('scrollbar.nvim', { clear = true })
    local events = vim.tbl_filter(function(ev)
        return vim.fn.exists('##' .. ev) == 1
    end, {
        'BufWinEnter',
        'WinEnter',
        'CursorMoved',
        'VimResized',
        'FocusGained',
        'WinScrolled',
    })
    vim.api.nvim_create_autocmd(events, {
        pattern = { '*' },
        callback = function(ev)
            if config.debug then
                log.info(ev.event .. ' event triggered, display scrollbar')
            end
            vim.schedule(M.show)
        end,
        group = augroup,
    })
    vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave', 'BufWinLeave', 'FocusLost' }, {
        pattern = { '*' },
        callback = function(ev)
            if config.debug then
                log.info(ev.event .. ' event triggered, clear scrollbar')
            end
            vim.schedule(function()
                local saved_ei = vim.o.eventignore
                vim.o.eventignore = 'all'
                M.clear()
                vim.o.eventignore = saved_ei
            end)
        end,
        group = augroup,
    })
end

return M
