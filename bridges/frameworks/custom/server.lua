NR.frameworks.custom = {
    init = function() return true end,
    player = function(source) return { name = GetPlayerName(source) } end
}
