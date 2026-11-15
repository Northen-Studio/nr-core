exports('NotifyPlayer', function(source, data)
    if not NR.ready then return false, 'not_ready' end
    if not NR.validSource(source) then return false, 'invalid_source' end
    local normalised, reason = NR.notification(data)
    if not normalised then return false, reason end
    TriggerClientEvent('nr-core:client:notify', source, normalised)
    return true
end)
