NR.frameworks.qbox = {
    init = function()
        if not NR.started('qbx_core') then return false, 'qbx_core must be started' end

        local data = exports.qbx_core:GetPlayerData()
        return data == nil or type(data) == 'table'
    end,
    player = function()
        if not LocalPlayer.state.isLoggedIn then return nil end
        return NR.fromQB(exports.qbx_core:GetPlayerData())
    end
}
