function NR.fromQB(data)
    if type(data) ~= 'table' or not data.citizenid then return nil end
    local info = type(data.charinfo) == 'table' and data.charinfo or {}
    local first, last = NR.text(info.firstname) or '', NR.text(info.lastname) or ''
    local job = type(data.job) == 'table' and data.job or {}
    return { identifier = data.citizenid, name = NR.text(first .. ' ' .. last),
        job = { name = job.name, label = job.label, grade = job.grade, onDuty = job.onduty } }
end

function NR.getPlayer(source)
    if not NR.ready then return nil, 'not_ready' end
    if NR.server and not NR.validSource(source) then return nil, 'invalid_source' end
    if not NR.adapter then
        return NR.playerData({ name = GetPlayerName(NR.server and source or PlayerId()) })
    end
    local data, reason = NR.safe('Player adapter', NR.adapter.player, source)
    if not data then return nil, reason or 'player_unloaded' end
    return NR.playerData(data)
end
