-- Though Tarantool has its own logging system
-- it would be better to has self-implemented logging system
-- - we may decide to save logs into file, output it in console, store it to database
-- or send to standalone logging server ( :-) ).
-- However basic logger implementation refers to Tarantool log module

local _log = require('log')

local function log(msg, lvl)
    if lvl == 'warn' then
        _log.warn(msg)
    elseif lvl == 'error' then
        _log.error(msg)
    elseif lvl == 'debug' then
        _log.debug(msg)
    elseif lvl == 'verbose' then
        _log.verbose(msg)
    else
        -- We suppose 'info' as default message type
        _log.info(msg)
    end

end


return {
    log = log
}