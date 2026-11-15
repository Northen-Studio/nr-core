local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    if not NR.started('es_extended') then return false, 'es_extended must be started' end
    object = exports.es_extended:getSharedObject()
    return type(object) == 'table' and type(object.GetPlayerData) == 'function'
        and type(object.IsPlayerLoaded) == 'function'
end
function adapter.object()
    if not object and not adapter.init() then return nil end
    return object
end
function adapter.player()
    local core = adapter.object()
    if not core or not core.IsPlayerLoaded() then return nil end
    local data = core.GetPlayerData()
    if not data or not data.identifier then return nil end
    return { identifier = data.identifier, name = data.name, job = data.job }
end
NR.frameworks.esx = adapter
