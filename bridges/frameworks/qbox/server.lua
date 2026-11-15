NR.frameworks.qbox = {
    init = function()
        if not NR.started('qbx_core') then return false, 'qbx_core must be started' end
        return type(exports.qbx_core:GetCoreVersion(GetCurrentResourceName())) == 'string'
    end,
    player = function(source)
        local player = exports.qbx_core:GetPlayer(source)
        return player and NR.fromQB(player.PlayerData) or nil
    end
}
