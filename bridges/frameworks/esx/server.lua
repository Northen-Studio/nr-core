local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    object = nil
    if not NR.started('es_extended') then return false, 'es_extended must be started' end
    local candidate = exports.es_extended:getSharedObject()
    local valid, reason = NR.checkMethods(candidate, { 'GetPlayerFromId' }, 'ESX')
    if not valid then return false, reason end
    object = candidate
    return true
end
function adapter.player(source)
    local player = object.GetPlayerFromId(source)
    if not player then return nil end
    return { identifier = player.getIdentifier(), name = player.getName(), job = player.getJob() }
end
NR.frameworks.esx = adapter
