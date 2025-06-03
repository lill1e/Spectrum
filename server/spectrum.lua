Spectrum = {
    debug = false,
    loaded = false,
    players = {},
    tokens = {},
    libs = {
        callbacks = {},
        callbackFunctions = {},
        callbackCounts = {},
        tokens = {}
    },
    items = {
        ["med_kit"] = {
            displayName = "Medical Grade Equipment",
            illegal = false,
            rare = true,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:SetHealth", source,
                    (GetEntityModel(GetPlayerPed(source)) == GetHashKey("mp_f_freemode_01")) and 175 or 200,
                    Spectrum.libs.Tokens.CreateToken(source))
            end,
            max = 5
        },
        ["box"] = {
            displayName = "Mystery Box",
            illegal = false,
            rare = false,
            usable = true,
            removeOnUse = false,
            swapOnUse = {
                item = "coin",
                quantity = 1
            },
            handler = false,
            max = 10
        },
        ["coin"] = {
            displayName = "Gold Coin",
            illegal = false,
            usable = true,
            rare = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:Notification", source,
                    "You flip a coin and notice it landed on: ~y~" .. (math.random(0, 1) == 1 and "Tails" or "Heads"))
            end,
            max = 3
        },
        ["blueprint"] = {
            displayName = "(Blue)print",
            illegal = true,
            rare = true,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:Notification", source, "~r~there goes your blueprint")
            end,
            max = 1
        }
    },
    weapons = {},
    weaponsData = {},
    jobs = {
        ["dealer"] = {},
        ["lspd"] = {},
        ["fib"] = {},
        ["doa"] = {}
    },
    stores = {
        twentyfourseven = {
            colour = "~g~",
            name = "24/7",
            range = 3,
            locations = {
                vector3(25.68324, -1347.402, 29.49702),
                vector3(373.8286, 326.4115, 103.5663),
                vector3(2556.944, 382.0442, 108.6228),
                vector3(2678.343, 3280.672, 55.24107),
                vector3(1960.985, 3740.966, 32.3437),
                vector3(547.8699, 2670.646, 42.15659),
                vector3(1729.107, 6414.98, 35.03717)
            },
            items = {
                coin = {
                    cost = 5,
                    type = 1,
                    clean = true
                },
                blueprint = {
                    quantity = 4,
                    cost = 4,
                    type = 1,
                    clean = false
                }
            },
            blip = {
                sprite = 52
            },
            -- A Menu is:
            -- title: String
            -- description: String
            -- banner: String | nil
            menu = {
                title = "#1",
                description = "~y~Just a simple store",
                banner = "shopui_title_conveniencestore"
            }
        },
        dealer = {
            colour = "~r~",
            name = "Limited Supply",
            range = 2,
            locations = {
                vector3(26.18591, -1299.739, 29.26874)
            },
            items = {
                blueprint = {
                    cost = 0,
                    type = 1,
                    clean = false
                },
                WEAPON_PISTOL = {
                    cost = 0,
                    type = 2,
                    clean = true
                },
                AMMO_PISTOL = {
                    quantity = 12,
                    cost = 0,
                    type = 3,
                    clean = true
                },
                med_kit = {
                    quantity = 1,
                    cost = 0,
                    type = 1,
                    clean = false
                }
            },
            menu = {
                title = "Backdoor",
                description = "~r~keep your mouth shut"
            }
        },
        forumDealer = {
            colour = "~o~",
            name = "Backdoor (Forum)",
            range = 3,
            attribute = "debug",
            blip = {},
            locations = {
                vector3(-256.1212, -1542.451, 31.9281)
            },
            items = {
                med_kit = {
                    cost = 0,
                    type = 1,
                    clean = false
                },
            },
            menu = {
                title = "Backdoor",
                description = "~r~keep your mouth shut"
            }
        },
        generalPurpose = {
            colour = "~y~",
            name = "Mega Mall",
            range = 2,
            blip = {
                sprite = 52
            },
            locations = {
                vector3(46.79566, -1749.575, 29.6328)
            },
            items = {
                blueprint = {
                    cost = 0,
                    type = 1,
                    clean = true
                }
            },
            menu = {
                title = "Mega Mall",
                description = "~y~General Purpose Goods"
            }
        },
        ltdGasoline = {
            colour = "~b~",
            name = "LTD Gasoline",
            range = 3,
            blip = {
                sprite = 52
            },
            locations = {
                vector3(-48.44455, -1757.967, 29.42103),
                vector3(-707.4072, -914.3958, 19.21557),
                vector3(1163.626, -323.8998, 69.20499),
                vector3(1698.122, 4924.427, 42.06372)
            },
            items = {},
            menu = {
                title = "",
                description = "unLTD great prices!",
                banner = "shopui_title_gasstation"
            }
        }
    }
}
