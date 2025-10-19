fx_version 'adamant'
games {'gta5'}
version '1.0'

author 'arimaya-selfstorage'
description 'arimaya-selfstorage - selfstorage'


client_scripts {
  'client/client.lua'
}

server_scripts {
  'server/server.lua'
}

ui_page 'dist/index.html'

files {
	'dist/index.html',
	'dist/assets/*.css',
	'dist/assets/*.js',
	'dist/assets/*.png',
}

shared_scripts {
	'config/config.lua'
}

server_script "@mysql-async/lib/MySQL.lua"server_scripts { '@mysql-async/lib/MySQL.lua' }