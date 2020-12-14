local cartridge = require('cartridge')
local errors = require('errors')

local function http_response(status, data)
    return {
        status = status,
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

local function get_file_content(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local function open_file(req)
    local key = req:stash('key')
    key = key or "index.html"
    local content = get_file_content('html/' .. key)
    if content == nil then
        return http_response(404, "Not Found")
    end
    return http_response(200, content)
end

local function init(opts)
    local httpd = cartridge.service_get('httpd')
    local err_httpd = errors.new_class("httpd error")

    if httpd == nil then
        return nil, err_httpd:new("not found")
    end;
    
    httpd:route({method = 'GET', path = '/ui-test/:key'}, open_file)
    
    local log = require('log')
    log.info('Test GUI started!')
    
    return true

end

return {
    role_name = 'app.roles.ui-test',
    init = init,
    -- dependencies = {'cartridge.roles.vshard-router'},
}