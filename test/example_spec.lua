-- test/example_spec.lua
-- Example test file demonstrating luaunit usage

local lu = require('luaunit')
local config = require('scrollbar.config')
local scrollbar = require('scrollbar')

TestExample = {}

function TestExample:setUp()
    config.setup({
        max_size = 10,
        min_size = 5,
        width = 1,
        right_offset = 1,
        debug = false,
    })
end

function TestExample:test_simple_assertion()
    lu.assertEquals(1 + 1, 2)
end

function TestExample:test_default_config()
    local cfg = config.setup()
    lu.assertEquals(cfg.max_size, 10)
    lu.assertEquals(cfg.min_size, 5)
    lu.assertEquals(cfg.width, 1)
    lu.assertEquals(cfg.right_offset, 1)
    lu.assertEquals(cfg.debug, false)
end

function TestExample:test_custom_config()
    local cfg = config.setup({
        max_size = 8,
        min_size = 3,
    })
    lu.assertEquals(cfg.max_size, 8)
    lu.assertEquals(cfg.min_size, 3)
end

function TestExample:test_get_position_basic()
    -- topline=1, total=100, height=30
    -- bar_size = fix_size(30 * 30 / 100) = fix_size(9) = 9
    -- precision = 30 - 9 = 21
    -- each_line = (100 - 30) / 21 = 70/21 ≈ 3.333
    -- row = floor((1 - 1) / 3.333) = 0
    local bar_size, row = scrollbar.get_position(1, 100, 30)
    lu.assertEquals(bar_size, 9)
    lu.assertEquals(row, 0)
end

function TestExample:test_get_position_scroll_down()
    -- topline=50, total=100, height=30
    -- bar_size = fix_size(30 * 30 / 100) = fix_size(9) = 9
    -- precision = 30 - 9 = 21
    -- each_line = (100 - 30) / 21 = 70/21 ≈ 3.333
    -- row = floor((50 - 1) / 3.333) = floor(14.7) = 14
    local bar_size, row = scrollbar.get_position(50, 100, 30)
    lu.assertEquals(bar_size, 9)
    lu.assertEquals(row, 14)
end

return TestExample

