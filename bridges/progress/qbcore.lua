NR.progressProviders.qbcore = {
    resource = 'progressbar',
    available = function() return NR.started('progressbar') end,
    busy = function() return exports.progressbar:isDoingSomething() == true end,
    start = function(data, done)
        exports.progressbar:Progress({ name = 'nr_core', label = data.label,
            duration = data.duration, useWhileDead = false, canCancel = data.canCancel,
            controlDisables = {}, animation = {}, prop = {}, propTwo = {} },
            function(cancelled) done(not cancelled, 'cancelled') end)
    end,
    cancel = function() TriggerEvent('progressbar:client:cancel') end
}
