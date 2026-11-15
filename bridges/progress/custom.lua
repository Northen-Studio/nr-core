NR.progressProviders.custom = {
    resource = 'progressbar',
    available = function() return NR.progressProviders.qbcore.available() end,
    busy = function() return NR.progressProviders.qbcore.busy() end,
    start = function(data, done) return NR.progressProviders.qbcore.start(data, done) end,
    cancel = function() return NR.progressProviders.qbcore.cancel() end
}
