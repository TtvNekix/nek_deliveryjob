fx_version 'cerulean'
game 'gta5'

shared_scripts {
    'config/*.lua',
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
