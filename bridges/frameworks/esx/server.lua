local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    if not NR.started('es_extended') then return false, 'es_extended must be started' end
    object = exports.es_extended:getSharedObject()
    return type(object) == 'table' and type(object.GetPlayerFromId) == 'function'
end
function adapter.player(source)
    local player = object.GetPlayerFromId(source)
    if not player then return nil end
    return { identifier = player.getIdentifier(), name = player.getName(), job = player.getJob() }
end
NR.frameworks.esx = adapter
