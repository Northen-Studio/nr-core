local active

function NR.cancelProgress(reason, resourceStopped)
    if not active then return end
    local operation = active
    operation.cancelling = true

    if not resourceStopped then
        NR.safe('Progress cleanup', operation.provider.cancel)
    end
    operation.cancelling = false
    operation.finish(false, reason or 'cancelled')
end

exports('Progress', function(data)
    if not NR.ready then return false, 'not_ready' end
    local normalised, reason = NR.progressData(data)
    if not normalised then return false, reason end
    if active then return false, 'busy' end
    local selected = NR.resolveProgress()
    if not selected then return false, 'provider_unavailable' end
    local provider = NR.progressProviders[selected]
    local busy, failure = NR.safe('Progress busy check', provider.busy)
    if busy == nil then return false, failure end
    if busy then return false, 'busy' end
    local result = promise.new()
    local operation = { provider = provider, owner = GetInvokingResource(), finished = false }
    function operation.finish(completed, errorCode)
        if operation.finished or operation.cancelling then return end
        operation.finished = true
        if active == operation then active = nil end
        local reason
        if completed ~= true then reason = errorCode or 'cancelled' end
        result:resolve({ completed == true, reason })
    end
    active = operation
    SetTimeout(normalised.duration + Config.Progress.timeoutGrace, function()
        if active == operation then NR.cancelProgress('timeout') end
    end)
    local ok, errorMessage = pcall(provider.start, normalised, operation.finish)
    if not ok then
        NR.log('ERROR', 'Progress start: ' .. tostring(errorMessage))
        if active == operation then NR.cancelProgress('provider_error') end
    end
    local value = Citizen.Await(result)
    return value[1], value[2] or nil
end)

AddEventHandler('onClientResourceStop', function(resource)
    if not active then return end
    if resource == active.provider.resource then NR.cancelProgress('provider_stopped', true)
    elseif resource == GetCurrentResourceName() or resource == active.owner then
        NR.cancelProgress('resource_stopped')
    end
end)
