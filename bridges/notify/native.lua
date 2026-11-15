NR.notifications.native = {
    available = function() return true end,
    send = function(data)
        BeginTextCommandThefeedPost('STRING')

        local message = NR.text(NR.message(data):gsub('~', ''), 99) or ''
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, false)
        return true
    end
}
