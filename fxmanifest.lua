name "qb-multijob"
author "QBCore Framework"
description "Multi Job Script for QBCore Framework"
fx_version "cerulean"
game "gta5"
version  '1.0.0'

client_scripts {
	'client/**.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/server_config.lua',
    'server/server.lua',
	'server/exports.lua',
}

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/*.lua',
	'shared/**.lua'
}

lua54 'yes'
