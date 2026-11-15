NR.notifications.esx = {
    available = function()

        if not NR.started('es_extended') or not NR.started('esx_notify') then return false end
        if NR.server then return true end
        local core = NR.frameworks.esx.object()
        return core ~= nil and NR.callable(core.ShowNotification)
    end,
    send = function(data)
        local core = NR.frameworks.esx.object()
        if not core then return false, 'provider_unavailable' end
        core.ShowNotification(NR.message(data), data.type, data.duration)
        return true
    end
}
