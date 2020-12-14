local cartridge = require('cartridge')
local errors = require('errors')
local log = require('app.logger')
local storage = require('app.kv-storage')
local limiter = require('app.limiter')

-- Though I hardcoded this value the best practice is to pass it from configuration files
-- Ilyas K
local api_limit = 100

local function check_limits()
    return limiter.limit_exceeded() == true
end

-- Common function for making HTTP response
local function kv_response(status, data)
    log.log('responded with ' .. status .. ' status code: ' .. data)
    return {
        status = status,
        -- Setting CORS policy for development needs
        headers = {
            ['content-type'] = 'text/html; charset=utf8',
            ['Access-Control-Allow-Origin']  = "*",
            ['Access-Control-Allow-Headers']  = "*",
            ['Access-Control-Allow-Methods']  = "*",
            ['Access-Control-Expose-Headers']  = "*"
        },
        body = data
    }
end

--  GET kv/:key
--  Find value by key in storage and send it to client
--  Returns 200 if key exists, otherwise returns 404
local function kv_get(req)
    -- Checking limits
    if check_limits() == true then
        return kv_response(429, "API requests limit exceeded")
    end

    local key = req:stash('key')

    log.log('GET ' .. key)

    local result = storage.get_value(key)
    
    if result.result == true then
        return kv_response(200, result.value)
    else
        return kv_response(404, "Not found")
    end
end

--  PUT kv/:key {value: 'val'}
--  Modifies existing value in storage by key
--  Returns 400 if query format is invalid
--  Returns 200 if key exists, otherwise returns 404
local function kv_put(req)
    -- Checking limits
    if check_limits() == true then
        return kv_response(429, "API requests limit exceeded")
    end

    local key = req:stash('key')
    
    local data = req:json()
    local value = data.value

    log.log('PUT ' .. key .. " / ")

    --check data format
    if value == nil then
        return kv_response(400, "Bad format")
    end

    -- check the key for existance before trying to update
    if storage.is_existing_value(key) == false then
        return kv_response(404, "Not found")
    end

    local result = storage.put_value(key, value)

    if result.result == true then
        return kv_response(200, "OK")
    else
        return kv_response(500, "Internal Server Error")
    end
end

--  POST kv { key: 'key', value: 'val'}
--  Creates new pair <key, value> in storage
--  Returns 400 if query format is invalid
--  Returns 200 if key does not exists, otherwise returns 409
local function kv_post(req)
    -- Checking limits
    if check_limits() == true then
        return kv_response(429, "API requests limit exceeded")
    end

    local data = req:json()
    local key = data.key
    local value = data.value

    log.log('POST ')

    --check data format
    if key == nil or value == nil then
        return kv_response(400, "Bad format")
    end

    log.log('POST ' .. key .. " / " .. value)

    -- check the key for existance before trying to insert
    if storage.is_existing_value(key) then
        return kv_response(409, "Already exists")
    end

    local result = storage.post_value(key, value)
    
    if result.result == true then
        return kv_response(200, "OK")
    else
        return kv_response(500, "Internal Server Error")
    end
end

--  DELETE kv/:key
--  Deletes value by key from storage
--  Returns 200 if key exists, otherwise returns 404
local function kv_delete(req)
    -- Checking limits
    if check_limits() == true then
        return kv_response(429, "API requests limit exceeded")
    end

    local key = req:stash('key')
    
    log.log('DELETE ' .. key)

    -- check the key for existance before trying to delete
    if storage.is_existing_value(key) == false then
        return kv_response(404, "Not found")
    end

    storage.delete_value(key)
    return kv_response(200, "OK")
end

local function init(opts)
    local httpd = cartridge.service_get('httpd')
    local err_httpd = errors.new_class("httpd error")

    if httpd == nil then
        return nil, err_httpd:new("not found")
    end;

    limiter.init(api_limit)
    storage.init()

    httpd:route({method = 'GET', path = '/kv/:key'}, kv_get)
    httpd:route({method = 'PUT', path = '/kv/:key'}, kv_put)
    httpd:route({method = 'POST', path = '/kv'}, kv_post)
    httpd:route({method = 'DELETE', path = '/kv/:key'}, kv_delete)

    log.log("KV Storage Server Started!")
    
    return true
end

return {
    role_name = 'app.roles.kv-router',
    init = init,
    -- dependencies = {'cartridge.roles.vshard-router'},
}