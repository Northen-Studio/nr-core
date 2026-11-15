fx_version 'cerulean'
game 'gta5'

author 'Northen Studio'
description 'A lightweight compatibility layer for Northen Studio resources.'
version '1.0.1'

shared_scripts {
    'config/shared.lua',
    'shared/constants.lua',
    'shared/utils.lua',
    'shared/validation.lua',
    'shared/player.lua',
    'shared/framework.lua',
    'bridges/frameworks/custom/shared.lua',
    'shared/providers.lua'
}

client_scripts {
    'bridges/frameworks/esx/client.lua',
    'bridges/frameworks/qbcore/client.lua',
    'bridges/frameworks/qbox/client.lua',
    'bridges/frameworks/custom/client.lua',
    'bridges/notify/native.lua',
    'bridges/notify/esx.lua',
    'bridges/notify/qbcore.lua',
    'bridges/notify/qbox.lua',
    'bridges/notify/ox_lib.lua',
    'bridges/notify/custom.lua',
    'bridges/progress/ox_lib.lua',
    'bridges/progress/qbcore.lua',
    'bridges/progress/custom.lua',
    'client/notify.lua',
    'client/progress.lua',
    'client/player.lua',
    'shared/lifecycle.lua'
}

server_scripts {
    'bridges/frameworks/esx/server.lua',
    'bridges/frameworks/qbcore/server.lua',
    'bridges/frameworks/qbox/server.lua',
    'bridges/frameworks/custom/server.lua',
    'bridges/notify/native.lua',
    'bridges/notify/esx.lua',
    'bridges/notify/qbcore.lua',
    'bridges/notify/qbox.lua',
    'bridges/notify/ox_lib.lua',
    'bridges/notify/custom.lua',
    'bridges/progress/ox_lib.lua',
    'bridges/progress/qbcore.lua',
    'bridges/progress/custom.lua',
    'server/notify.lua',
    'server/player.lua',
    'server/banner.lua',
    'shared/lifecycle.lua'
}
