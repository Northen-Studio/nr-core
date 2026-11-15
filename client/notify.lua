function NR.notify(data)
    if not NR.ready then return false, 'not_ready' end
    local normalised, reason = NR.notification(data)
    if not normalised then return false, reason end
    local provider = NR.resolveNotification()
    if not provider then return false, 'provider_unavailable' end

    local ok, failure = NR.safe('Notification: ' .. provider, NR.notifications[provider].send, normalised)
    if ok == true then return true end
    return false, failure or 'provider_error'
end
exports('Notify', NR.notify)
RegisterNetEvent('nr-core:client:notify', function(data)
    if source ~= 65535 then return end
    local ok, reason = NR.notify(data)
    if not ok then NR.log('DEBUG', 'Notification rejected: ' .. tostring(reason)) end
end)
