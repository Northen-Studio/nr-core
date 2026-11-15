local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    if not NR.started('qb-core') then return false, 'A real qb-core resource must be started' end
    object = exports['qb-core']:GetCoreObject()
    return type(object) == 'table' and type(object.Functions) == 'table'
        and type(object.Functions.GetPlayerData) == 'function'
end
function adapter.object()
    if not object and not adapter.init() then return nil end
    return object
end
function adapter.player()
    if not LocalPlayer.state.isLoggedIn then return nil end
    return NR.fromQB(adapter.object().Functions.GetPlayerData())
end
NR.frameworks.qbcore = adapter
