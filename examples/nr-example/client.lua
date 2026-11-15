RegisterNetEvent('nr-example:run', function()
    if source ~= 65535 then return end
    local framework, reason = exports['nr-core']:GetFramework()
    print(('Framework: %s (%s)'):format(tostring(framework), tostring(reason)))
    local notified, errorCode = exports['nr-core']:Notify({
        title = 'Northen Studio', description = 'Development example started.', type = 'info'
    })
    if not notified then print('Notify failed: ' .. tostring(errorCode)) end
    local completed, progressError = exports['nr-core']:Progress({
        label = 'Testing progress...', duration = 3000, canCancel = true
    })
    print(('Progress: %s (%s)'):format(tostring(completed), tostring(progressError)))
    local player, playerError = exports['nr-core']:GetPlayerData()
    if player then
        print(('Player: %s; job: %s'):format(player.name or 'unavailable', player.job.name or 'unavailable'))
    else
        print('Player unavailable: ' .. tostring(playerError))
    end
end)
