NR.notifications.custom = {
    available = function() return true end,
    send = function(data) return NR.notifications.native.send(data) end
}
