function NR.log(level, message)
    if level == 'DEBUG' and not Config.Debug then return end
    print(('[nr-core] [%s] %s'):format(level, tostring(message)))
end

function NR.started(resource)
    return GetResourceState(resource) == 'started'
end

function NR.callable(value)
    if type(value) == 'function' then return true end
    if type(value) ~= 'table' then return false end
    local metatable = getmetatable(value)
    return type(metatable) == 'table' and type(rawget(metatable, '__call')) == 'function'
end

function NR.checkMethods(object, names, label)
    if type(object) ~= 'table' then
        return false, label .. ' API must be a table; received ' .. type(object)
    end
    for _, name in ipairs(names) do
        if not NR.callable(object[name]) then
            return false, label .. '.' .. name .. ' is not callable; received ' .. type(object[name])
        end
    end
    return true
end

function NR.text(value, limit)
    if type(value) ~= 'string' then return nil end
    if not utf8.len(value) then return nil end
    value = value:gsub('[%c]', ' ')
    limit = limit or 256
    if #value > limit then

        local boundary = utf8.offset(value, 0, limit + 1)
        value = value:sub(1, boundary - 1)
    end
    return value:match('%S') and value or nil
end

function NR.integer(value, minimum, maximum)
    return type(value) == 'number' and value == value and value % 1 == 0
        and value >= minimum and value <= maximum
end

function NR.validSource(value)
    return NR.integer(value, 1, 2147483647) and GetPlayerName(value) ~= nil
end

function NR.safe(label, callback, ...)
    local ok, value, reason = pcall(callback, ...)
    if not ok then
        NR.log('ERROR', label .. ': ' .. tostring(value))
        return nil, 'provider_error'
    end
    return value, reason
end

function NR.message(data)
    if data.title and data.description then return data.title .. ': ' .. data.description end
    return data.description or data.title
end
