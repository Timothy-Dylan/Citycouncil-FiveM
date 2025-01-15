fx_version 'cerulean'
game { 'gta5' }
lua54 'yes'

author 'Timothyy_'
name 'rd_citycouncil'
description 'A script that creates a usage for a city council system'

version 'active-development'
license 'LGPL-3.0-or-later'
repository 'https://github.com/Timothy-Dylan/Redemption-Citycouncil'

dependencies {
    '/server:7290',
    '/onesync',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/*.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/modules/*.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/*.lua',
    'server/*.lua',
}

files {
    'config/*.lua',
    'web/index.html',
    'web/js/*.js',
    'web/css/*.css',
}