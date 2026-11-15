local object
local adapter = {}
function adapter.reset() object = nil end
function adapter.init()
    object = nil
    if not NR.started('qb-core') then return false, 'A real qb-core resource must be started' end
    local candidate = exports['qb-core']:GetCoreObject()
    local functions = type(candidate) == 'table' and candidate.Functions or nil
    local valid, reason = NR.checkMethods(functions, { 'GetPlayer' }, 'QBCore.Functions')
    if not valid then return false, reason end
    object = candidate
    return true
end
function adapter.player(source)
    local player = object.Functions.GetPlayer(source)
    return player and NR.fromQB(player.PlayerData) or nil
end
NR.frameworks.qbcore = adapter
