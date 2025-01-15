local main_config = require('config.main')

-- Checks if the main configs exist
assert(main_config ~= nil or next(main_config) ~= nil, 'Main Config is missing or empty')

lib.locale()

function Debug(...)
    if main_config.Debug then
        lib.print.info(...)
    end
end