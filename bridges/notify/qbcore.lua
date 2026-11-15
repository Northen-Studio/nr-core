NR.notifications.qbcore = {
    available = function()
        if not NR.started('qb-core') then return false end
        if NR.server then return true end
        local core = NR.frameworks.qbcore.object()
        return core ~= nil and type(core.Functions.Notify) == 'function'
    end,
    send = function(data)
        local core = NR.frameworks.qbcore.object()
        if not core then return false, 'provider_unavailable' end
        local kind = ({ info = 'primary', warning = 'primary' })[data.type] or data.type
        local text = data.title and data.description
            and { text = data.title, caption = data.description } or NR.message(data)
        core.Functions.Notify(text, kind, data.duration)
        return true
    end
}
