-- Current module describes storage creation and CRUD operations
-- Ilyas K

local checks = require('checks')
local errors = require('errors')
local kv_err = errors.new_class("Key/Value Storage Error")

-- Creates new Tarantool schema
-- I use sring key though I realize that unsigned may be better for refromance
local function init()
    local kv = box.schema.space.create(
        'kv',
        {
            format = {
                {'key', 'string'},
                {'value', 'string'},
            },

            if_not_exists = true,
        }
    )

    kv:create_index('key', {
        parts = {'key'},
        unique = true,
        if_not_exists = true,
    })
end

-- Checks is current key exists
local function is_existing_value(key)
    checks('string')
    local exists = box.space.kv:get(key)

    return exists ~= nil
end

-- Returns value by key
-- In case tuple does not exists returns nil
local function get_value(key)
    checks('string')
    local exists = box.space.kv:get(key)
    
    if exists == nil then
        return { result = false, value = nil }
    end

    return { result = true, value = exists.value }
end

-- Updates value is it exists
-- Checking key for existance will be good practice
local function put_value(key, value)
    checks('string', 'string')
    local exists = box.space.kv:get(key)
    
    if exists == nil then
        return { result = false, error = kv_err:new("Such key does not exists") }
    end

    box.space.kv:update(key, {{ '=', 'value', value }})

    return { result = true, error = nil }
end

-- Inserts new value into table
-- Checking key for existance will be good practice
local function post_value(key, value)
    checks('string', 'string')
    local exists = box.space.kv:get(key)
    
    if exists ~= nil then
        return { result = false, error = kv_err:new("Such key already exists") }
    end

    box.space.kv:insert({ key, value })

    return { result = true, error = nil }
end

-- Deletes value by key if it exists
-- Does not return anything
local function delete_value(key)
    checks('string')

    local exists = box.space.kv:get(key)
    if exists ~= nil then
        box.space.kv:delete(key)
    end
end

return {
    init = init,
    is_existing_value = is_existing_value,
    get_value = get_value,
    put_value = put_value,
    post_value = post_value,
    delete_value = delete_value
}

