fx_version "cerulean"
game "gta5"

loadscreen_manual_shutdown "yes"

author "lillie"
description "wtf is this :smirk_cat:"

shared_scripts {
    "shared/config.lua",
    "shared/*.lua"
}

version "1.0.0"

files {
    "html/*.html",
    "html/css/*.css",
    "html/js/*.js",
    "html/fonts/*.ttf"
}

ui_page "html/ui.html"

client_scripts {
    "RageUI/RageUI.lua",
    "RageUI/Menu.lua",
    "RageUI/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/elements/*.lua",
    "RageUI/items/*.lua",
    "client/spectrum.lua",
    "client/*.lua",
    "client/jobs/*.lua"
}

server_scripts {
    "server/spectrum.lua",
    "server/*.lua"
}
