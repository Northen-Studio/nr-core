local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    object = nil
    if not NR.started('qb-core') then return false, 'A real qb-core resource must be started' end
    local candidate = exports['qb-core']:GetCoreObject()
    local functions = type(candidate) == 'table' and candidate.Functions or nil
    local valid, reason = NR.checkMethods(functions, { 'GetPlayerData' }, 'QBCore.Functions')
    if not valid then return false, reason end
    object = candidate
    return true
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
