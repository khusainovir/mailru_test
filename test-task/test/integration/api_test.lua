local t = require('luatest')
local g = t.group('integration_api')

local helper = require('test.helper.integration')
local cluster = helper.cluster

g.test_sample = function()
    local server = cluster.main_server
    local response = server:http_request('post', '/admin/api', {json = {query = '{}'}})
    t.assert_equals(response.json, {data = {}})
    t.assert_equals(server.net_box:eval('return box.cfg.memtx_dir'), server.workdir)
end

g.test_kv_get_404 = function()
    local server = cluster.main_server
    local response = server:http_request('get', '/kv/test', {raise = false})
    t.assert_equals(response.status, 404)
end

g.test_kv_post_get = function()
    local server = cluster.main_server
    local response = server:http_request('post', '/kv', {raise = false, json = { key = "test", value = "val" }})
    t.assert_equals(response.status, 200)
    response = server:http_request('get', '/kv/test', {raise = false})
    t.assert_equals(response.status, 200)
    t.assert_equals(response.body, "val")
end

g.test_kv_delete = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    t.assert_equals(response.status, 200)
    response = server:http_request('get', '/kv/test', {raise = false})
    t.assert_equals(response.status, 404)
end

g.test_kv_delete_404 = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    response = server:http_request('delete', '/kv/test', {raise = false})
    t.assert_equals(response.status, 404)
end

g.test_kv_post_duplicate = function()
    local server = cluster.main_server
    local response = server:http_request('post', '/kv', {raise = false, json = { key = "test", value = "val" }})
    t.assert_equals(response.status, 200)
    response = server:http_request('post', '/kv', {raise = false, json = { key = "test", value = "val" }})
    t.assert_equals(response.status, 409)
    response = server:http_request('delete', '/kv/test', {raise = false})
    t.assert_equals(response.status, 200)
end

g.test_kv_put_exist = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    response = server:http_request('post', '/kv', {raise = false, json = { key = "test", value = "val" }})
    t.assert_equals(response.status, 200)
    response = server:http_request('put', '/kv/test', {raise = false, json = { value = "newval" }})
    t.assert_equals(response.status, 200)
    response = server:http_request('get', '/kv/test', {raise = false})
    t.assert_equals(response.status, 200)
    t.assert_equals(response.body, "newval")
end

g.test_kv_put_unexist = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    response = server:http_request('put', '/kv/test', {raise = false, json = { value = "newval" }})
    t.assert_equals(response.status, 404)
end

g.test_kv_put_400 = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    response = server:http_request('post', '/kv', {raise = false, json = { key = "test", value = "val" }})
    t.assert_equals(response.status, 200)
    response = server:http_request('put', '/kv/test', {raise = false, json = {  }})
    t.assert_equals(response.status, 400)
end

g.test_kv_post_400 = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    response = server:http_request('post', '/kv', {raise = false, json = { key = "test" }})
    t.assert_equals(response.status, 400)
    response = server:http_request('post', '/kv', {raise = false, json = {  value = "val" }})
    t.assert_equals(response.status, 400)
end

g.test_kv_429 = function()
    local server = cluster.main_server
    local response = server:http_request('delete', '/kv/test', {raise = false})
    response = server:http_request('post', '/kv', {raise = false, json = { key = "test", value="val" }})
    for i=1,200 do
        response = server:http_request('get', '/kv/test', {raise = false, json = { key = "test" }})
    end
    t.assert_equals(response.status, 429)
end
