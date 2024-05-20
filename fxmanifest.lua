fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Soufiane'
description 'Simple script to transfer you vehicle to another player'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
} 
client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
} 

dependencies {'qb-core', 'oxmysql', 'ox_lib'}    