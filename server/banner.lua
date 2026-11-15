function NR.banner()
    local resource = NR.text(GetCurrentResourceName(), 80)
    local version = NR.text(GetResourceMetadata(GetCurrentResourceName(), 'version', 0), 80) or 'unknown'
    print([[
 _   _ ____         ____ ___  ____  _____
| \ | |  _ \       / ___/ _ \|  _ \| ____|
|  \| | |_) |_____| |  | | | | |_) |  _|
| |\  |  _ <_____| |__| |_| |  _ <| |___
|_| \_|_| \_\      \____\___/|_| \_\_____|
========================================================
                    NORTHEN STUDIO
========================================================]])
    local function row(label, value) print(('  %-16s %s'):format(label, value)) end
    row('[SUCCESS]', 'Core initialised successfully')
    row('Resource:', resource)
    row('Version:', version)
    row('Developer:', 'Northen Studio')
    row('Framework:', NR.framework)
    row('Notifications:', (NR.notificationProvider or 'unavailable') .. ' (configured: ' .. Config.Notify.provider .. ')')
    row('Progress:', (NR.progressProvider or 'unavailable') .. ' (configured: ' .. Config.Progress.provider .. ')')
    print('--------------------------------------------------------')
    row('[LICENCE]', 'Static metadata; no online validation')
    row('Licence ID:', NR.text(Config.Licence.id, 80))
    row('Licence type:', NR.text(Config.Licence.type, 80))
    print('========================================================')
    print('       Northen Studio - Quality First. Always.')
    print('========================================================')
end
