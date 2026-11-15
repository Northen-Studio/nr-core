RegisterCommand('nrtest', function(source, args)
    local target = source > 0 and source or tonumber(args[1])
    if not target or target % 1 ~= 0 or target <= 0 or not GetPlayerName(target) then
        print('[nr-example] Usage: nrtest [connected player ID, console only]')
        return
    end
    local player, reason = exports['nr-core']:GetPlayerData(target)
    print(('[nr-example] Server player: %s (%s)'):format(player and player.name or 'unavailable', tostring(reason)))
    local ok, errorCode = exports['nr-core']:NotifyPlayer(target, {
        title = 'Northen Studio', description = 'Server notification test.', type = 'success'
    })
    if not ok then print('[nr-example] Notification failed: ' .. tostring(errorCode)); return end
    TriggerClientEvent('nr-example:run', target)
end, true)
