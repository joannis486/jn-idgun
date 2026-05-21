fx_version 'cerulean'
game 'gta5'

author 'ByJanni'
description 'jn-idgun — Modern Entity Inspector for FiveM (QBox, QBCore, ESX, Standalone)'
version '1.0.0'
repository 'https://github.com/joannis486/jn-idgun'

lua54 'yes'

shared_scripts {
    'config.lua',
    'shared/locale.lua'
}

client_scripts {
    'client/bridge.lua',
    'client/main.lua',
    'client/nui.lua'
}

server_scripts {
    'server/bridge.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'data/hashes.json',
    'locales/en.json',
    'locales/de.json'
}
