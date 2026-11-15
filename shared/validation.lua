function NR.validateConfig()
    if type(Config) ~= 'table' then return false, 'Config must be a table' end
    local frameworks = { auto = true, standalone = true, custom = true, esx = true, qbcore = true, qbox = true }
    local notify = { auto = true, native = true, custom = true, esx = true, qbcore = true, qbox = true, ox_lib = true }
    local progress = { auto = true, custom = true, qbcore = true, ox_lib = true }
    if not frameworks[Config.Framework] then return false, 'Invalid Config.Framework' end
    if type(Config.CustomResources) ~= 'table' then return false, 'Config.CustomResources must be a list' end
    for index, resource in pairs(Config.CustomResources) do
        if not NR.integer(index, 1, #Config.CustomResources) or type(resource) ~= 'string'
            or not resource:match('^[%w_.-]+$') then return false, 'Invalid Config.CustomResources entry' end
    end
    if type(Config.Debug) ~= 'boolean' then return false, 'Config.Debug must be boolean' end
    if type(Config.Notify) ~= 'table' or not notify[Config.Notify.provider]
        or not notify[Config.Notify.fallback] or Config.Notify.fallback == 'auto'
        or not NR.integer(Config.Notify.defaultDuration, 1, 60000)
        or not NR.positions[Config.Notify.defaultPosition]
        or (Config.Notify.oxInfoType ~= 'info' and Config.Notify.oxInfoType ~= 'inform')
        or type(Config.Notify.allowFallback) ~= 'boolean' then
        return false, 'Invalid Config.Notify; check provider, fallback, duration, position and allowFallback'
    end
    if type(Config.Progress) ~= 'table' or not progress[Config.Progress.provider]
        or type(Config.Progress.allowCancel) ~= 'boolean'
        or not NR.integer(Config.Progress.timeoutGrace, 1000, 30000) then
        return false, 'Invalid Config.Progress'
    end
    if type(Config.Licence) ~= 'table' or not NR.text(Config.Licence.id, 80)
        or not NR.text(Config.Licence.type, 80) then return false, 'Invalid Config.Licence metadata' end
    return true
end

function NR.notification(data)
    if type(data) ~= 'table' then return nil, 'invalid_data' end
    local title, description = NR.text(data.title), NR.text(data.description, 1000)
    if not title and not description then return nil, 'empty_message' end
    local duration = data.duration == nil and Config.Notify.defaultDuration or data.duration
    if not NR.integer(duration, 1, 60000) then return nil, 'invalid_duration' end
    local kind = data.type or 'info'
    if not ({ success = true, error = true, warning = true, info = true })[kind] then return nil, 'invalid_type' end
    local position = data.position or Config.Notify.defaultPosition
    if not NR.positions[position] then return nil, 'invalid_position' end
    return { title = title, description = description, duration = duration, type = kind, position = position }
end

function NR.progressData(data)
    if type(data) ~= 'table' then return nil, 'invalid_data' end
    if not NR.integer(data.duration, 1, 3600000) then return nil, 'invalid_duration' end
    local label = NR.text(data.label)
    if not label then return nil, 'invalid_label' end
    if data.canCancel ~= nil and type(data.canCancel) ~= 'boolean' then return nil, 'invalid_cancel' end
    return { label = label, duration = data.duration,
        canCancel = Config.Progress.allowCancel and data.canCancel ~= false }
end

function NR.playerData(data)
    if type(data) ~= 'table' then return nil, 'player_unloaded' end
    local job = type(data.job) == 'table' and data.job or {}
    local grade = type(job.grade) == 'table' and job.grade.level or job.grade
    local duty
    if type(job.onDuty) == 'boolean' then duty = job.onDuty end
    return {
        identifier = NR.text(data.identifier), name = NR.text(data.name),
        job = { name = NR.text(job.name), label = NR.text(job.label),
            grade = NR.integer(grade, 0, 100000) and grade or nil,
            onDuty = duty }
    }
end
