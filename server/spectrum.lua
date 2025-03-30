Spectrum = {
    debug = true,
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
            end
        },
        ["box"] = {
            displayName = "Mystery Box",
            illegal = false,
            rare = false,
            usable = true,
            removeOnUse = false,
            swapOnUse = {
                item = "coin",
                quantity = 5
            },
            handler = false,
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
            end
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
        simple = {
            colour = "~b~",
            name = "SimpleStore",
            range = 3,
            locations = {
                vector3(25.68324, -1347.402, 29.49702)
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
                sprite = -1,
                colour = -1
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
            blip = {
                -- TODO
            },
            menu = {
                title = "Backdoor",
                description = "~r~keep your mouth shut"
            }
        }
    }
}
