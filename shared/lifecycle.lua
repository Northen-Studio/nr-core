local bannerPrinted = false
local refreshPending = false

function NR.initialise()
    NR.ready = false
    local valid, reason = NR.validateConfig()
    if not valid then NR.log('ERROR', 'Initialisation failed: ' .. reason); return end
    local ok
    ok, reason = NR.refreshFramework()
    if not ok then NR.log('ERROR', 'Initialisation failed: ' .. tostring(reason)); return end
    NR.notificationProvider = NR.resolveNotification()
    NR.progressProvider = NR.resolveProgress()
    if not NR.notificationProvider then NR.log('WARN', 'Notification provider unavailable; Notify will fail safely.') end
    if not NR.progressProvider then NR.log('WARN', 'Progress provider unavailable; Progress will fail safely.') end
    if Config.Notify.provider ~= 'auto' and NR.notificationProvider ~= Config.Notify.provider then
        NR.log('WARN', 'Configured notification provider unavailable: ' .. Config.Notify.provider
            .. '; resolved: ' .. tostring(NR.notificationProvider))
    end
    if NR.server and not bannerPrinted then
        NR.banner()
        bannerPrinted = true
    end
    NR.ready = true
    NR.log('INFO', ('Ready; framework=%s, notifications=%s, progress=%s'):format(
        NR.framework, NR.notificationProvider or 'unavailable', NR.progressProvider or 'unavailable'))

    TriggerEvent('nr-core:ready', NR.framework)
end

local startEvent = NR.server and 'onResourceStart' or 'onClientResourceStart'
local stopEvent = NR.server and 'onResourceStop' or 'onClientResourceStop'
local function scheduleRefresh()
    if refreshPending then return end
    refreshPending = true
    SetTimeout(0, function()
        refreshPending = false
        NR.initialise()
    end)
end
AddEventHandler(startEvent, function(resource)
    if resource == GetCurrentResourceName() or NR.watched[resource] then

        scheduleRefresh()
    end
end)
AddEventHandler(stopEvent, function(resource)
    if resource == GetCurrentResourceName() then NR.ready = false; return end
    if NR.watched[resource] then
        NR.ready, NR.adapter, NR.framework = false, nil, nil
        for _, adapter in pairs(NR.frameworks) do if adapter.reset then adapter.reset() end end
        scheduleRefresh()
    end
end)
