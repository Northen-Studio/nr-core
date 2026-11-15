NR.frameworks.custom = {
    init = function() return true end,
    player = function() return { name = GetPlayerName(PlayerId()) } end
}
