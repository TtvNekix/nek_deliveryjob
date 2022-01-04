fx_version 'cerulean'
game 'gta5'
author 'Nekix for BellaCiao Roleplay'

shared_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/*.html',
    'ui/*.js',
    'ui/*.css',
}