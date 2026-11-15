for _, resource in ipairs(type(Config.CustomResources) == 'table' and Config.CustomResources or {}) do
    if type(resource) == 'string' and resource:match('^[%w_.-]+$') then
        NR.watched[resource] = true
    end
end
