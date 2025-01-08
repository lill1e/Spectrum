fx_version "cerulean"
game "gta5"

loadscreen_manual_shutdown "yes"

author "lillie"
description "wtf is this :smirk_cat:"
version "1.0.0"

client_scripts {
    "RageUI/RageUI.lua",
    "RageUI/Menu.lua",
    "RageUI/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/elements/*.lua",
    "RageUI/items/*.lua",
    "client/spectrum.lua",
    "client/*.lua"
}

server_scripts {
    "server/spectrum.lua",
    "server/*.lua"
}

shared_scripts {
    "shared/*.lua"
}
