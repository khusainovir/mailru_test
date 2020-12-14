local clock = require('clock')
local List = require('app.list').List
local log = require('log')

local list = {}
local limit = 0

-- returns current time in milliseconds
local function ts()
    return clock.realtime64() / 1000000
end


local function limit_exceeded()
    local now = ts()
    
    List.pushright(list, now)
    
    if list.last - list.first >= limit then
        local tmp = List.popleft(list)
        if now - tmp < 1000 then
            return true
        end
    end
    return false
end

local function init(lim_size)
    limit = lim_size
    list = List.new()
end

return {
    init = init,
    limit_exceeded = limit_exceeded,
}