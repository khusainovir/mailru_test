local t = require('luatest')

local cartridge_helpers = require('cartridge.test-helpers')
local shared = require('test.helper')

local helper = {shared = shared}

helper.cluster = cartridge_helpers.Cluster:new({
    server_command = shared.server_command,
    datadir = shared.datadir,
    use_vshard = false,
    replicasets = {
        {
            alias = 'api',
            uuid = cartridge_helpers.uuid('a'),
            roles = {'app.roles.kv-router'},
            servers = {
				{ instance_uuid = cartridge_helpers.uuid('a', 1) }
			},
        },
    },
})

t.before_suite(function() helper.cluster:start() end)
t.after_suite(function() helper.cluster:stop() end)

return helper
