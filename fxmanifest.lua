-- Script Metadata
fx_version 'cerulean'
game 'gta5'
-- Script info
author 'MineCop'
description 'MineCop Banking'
version '0.4 Alpha'
-- Script files
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*lua',
	'config.lua',
	'server/*.lua'
}
client_scripts {
	'@es_extended/locale.lua',
	'locales/*lua',
	'config.lua',
	'client/*.lua'
}
-- UI page
ui_page('html/UI.html')
files({
    'html/UI.html',
	'html/css/*.css',
	'html/js/*.js',
	'html/sounds/*.ogg',
	'html/img/*.png',
	'html/img/*.gif',
	'html/img/*.svg'
})
-- Script starts after
dependencies {
	'es_extended'
}