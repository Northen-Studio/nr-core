NR.notifications.qbox = {
    available = function() return NR.started('qbx_core') end,
    send = function(data)

        local kind = data.type == 'info' and Config.Notify.oxInfoType or data.type
        exports.qbx_core:Notify(data.title or data.description, kind, data.duration,
            data.title and data.description or nil, data.position)
        return true
    end
}
