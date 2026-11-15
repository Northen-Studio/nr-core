function NR.refreshFramework()
    NR.ready, NR.framework, NR.adapter = false, nil, nil

    for _, adapter in pairs(NR.frameworks) do
        if adapter.reset then adapter.reset() end
    end
    local selected = Config.Framework
    if selected == 'auto' then
        local candidates = {}
        if NR.started('qbx_core') then candidates[#candidates + 1] = 'qbox' end

        if NR.started('qb-core') then candidates[#candidates + 1] = 'qbcore' end
        if NR.started('es_extended') then candidates[#candidates + 1] = 'esx' end
        if #candidates > 1 then
            return false, 'Multiple frameworks started: ' .. table.concat(candidates, ', ') .. '. Set Config.Framework explicitly.'
        end
        selected = candidates[1] or 'standalone'
        if selected == 'standalone' then NR.log('WARN', 'No framework started; using standalone mode.') end
    else
        local count = 0
        for _, resource in pairs(NR.resources) do if NR.started(resource) then count = count + 1 end end
        if count > 1 then NR.log('WARN', 'Multiple frameworks started; explicit selection: ' .. selected) end
    end
    if selected ~= 'standalone' then
        local adapter = NR.frameworks[selected]
        if not adapter then return false, 'Framework adapter missing: ' .. selected end
        local ok, reason = NR.safe('Framework initialisation', adapter.init)
        if not ok then return false, reason or ('Framework unavailable: ' .. selected) end
        NR.adapter = adapter
    end
    NR.framework = selected
    return true
end

exports('GetFramework', function()
    if not NR.ready then return nil, 'not_ready' end
    return NR.framework
end)
