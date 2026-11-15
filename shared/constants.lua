NR = {
    frameworks = {}, notifications = {}, progressProviders = {},
    ready = false, framework = nil, adapter = nil,
    server = IsDuplicityVersion(),
    resources = { esx = 'es_extended', qbcore = 'qb-core', qbox = 'qbx_core' },
    watched = { es_extended = true, ['qb-core'] = true, qbx_core = true,
        ox_lib = true, progressbar = true, esx_notify = true },
    positions = { top = true, ['top-right'] = true, ['top-left'] = true,
        bottom = true, ['bottom-right'] = true, ['bottom-left'] = true,
        ['center-right'] = true, ['center-left'] = true }
}
