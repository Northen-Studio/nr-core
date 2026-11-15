function NR.available(registry, name)
    local adapter = registry[name]
    return adapter and NR.safe('Provider check: ' .. name, adapter.available) == true
end

function NR.resolveNotification()
    local selected = Config.Notify.provider
    if selected == 'auto' then
        if NR.available(NR.notifications, 'ox_lib') then return 'ox_lib' end
        if NR.available(NR.notifications, NR.framework) then return NR.framework end
        return 'native'
    end
    if NR.available(NR.notifications, selected) then return selected end
    if Config.Notify.allowFallback and NR.available(NR.notifications, Config.Notify.fallback) then
        return Config.Notify.fallback
    end
end

function NR.resolveProgress()
    local selected = Config.Progress.provider
    if selected ~= 'auto' then
        return NR.available(NR.progressProviders, selected) and selected or nil
    end
    for _, name in ipairs({ 'ox_lib', 'qbcore' }) do
        if NR.available(NR.progressProviders, name) then return name end
    end
end
