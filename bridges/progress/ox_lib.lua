NR.progressProviders.ox_lib = {
    resource = 'ox_lib',
    available = function()
        return NR.started('ox_lib') and (NR.server or exports.ox_lib:hasLoaded() == true)
    end,
    busy = function() return exports.ox_lib:progressActive() == true end,
    start = function(data, done)
        CreateThread(function()
            local ok, result = pcall(function() return exports.ox_lib:progressBar(data) end)
            if not ok then NR.log('ERROR', 'ox_lib progress: ' .. tostring(result)) end
            done(ok and result == true, ok and 'cancelled' or 'provider_error')
        end)
    end,
    cancel = function() exports.ox_lib:cancelProgress() end
}
