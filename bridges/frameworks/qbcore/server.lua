local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    if not NR.started('qb-core') then return false, 'A real qb-core resource must be started' end
    object = exports['qb-core']:GetCoreObject()
    return type(object) == 'table' and type(object.Functions) == 'table'
        and type(object.Functions.GetPlayer) == 'function'
end
function adapter.player(source)
    local player = object.Functions.GetPlayer(source)
    return player and NR.fromQB(player.PlayerData) or nil
end
NR.frameworks.qbcore = adapter
