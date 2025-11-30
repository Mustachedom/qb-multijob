fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Core resource for the framework, contains all the core functionality and features'
version '1.3.0'
ui_page 'web/build/index.html'
shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/en.lua',
  'locales/*.lua'
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}


files {
  'web/build/index.html',
  'web/build/**/*'
}
