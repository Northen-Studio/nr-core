NR.notifications.ox_lib = {
    available = function()
        if not NR.started('ox_lib') then return false end
        if NR.server then return true end
        return exports.ox_lib:hasLoaded() == true
    end,
    send = function(data)
        if data.type == 'info' then data.type = Config.Notify.oxInfoType end
        exports.ox_lib:notify(data)
        return true
    end
}
