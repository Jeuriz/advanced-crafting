fx_version 'cerulean'
game 'gta5'

name 'Advanced Crafting System'
author 'TuNombre'
version '2.1.0'
description 'Sistema avanzado de crafting para QBCore con soporte para tgiann inventory'

-- Dependencias
dependencies {
    'qb-core',
    'ox_target',
    'tgiann-inventory',
    'oxmysql'
}

-- Configuración compartida
shared_scripts {
    'config.lua'
}

-- Scripts del servidor
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

-- Scripts del cliente
client_scripts {
    'client.lua'
}

-- Archivos de la UI
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- Configuración de versión de Lua
lua54 'yes'

-- Configuración adicional
escrow_ignore {
    'client.lua',
    'server.lua',
    'html/**/*'
}
