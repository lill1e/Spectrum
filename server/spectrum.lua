Spectrum = {
    debug = false,
    loaded = false,
    locked = true,
    closed = true,
    start = nil,
    players = {},
    reports = {},
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
        },
        ["repair_kit"] = {
            displayName = "Repair Kit",
            illegal = false,
            rare = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:Notification", source,
                    "TBD")
            end,
            max = 3
        },
        ["electronics"] = {
            displayName = "Electronic Parts",
            illegal = false,
            rare = true,
            removeOnUse = false,
            swapOnUse = false,
            max = 10
        },
        ["ammo_pistol"] = {
            displayName = "Ammo Pack (Handgun) - 30 Rounds",
            illegal = false,
            rare = false,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                AddAmmo(source, "AMMO_PISTOL", 30)
            end,
            max = 3
        },
        ["ammo_shotgun"] = {
            displayName = "Ammo Pack (Shotgun) - 30 Rounds",
            illegal = false,
            rare = false,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                AddAmmo(source, "AMMO_SHOTGUN", 30)
            end,
            max = 3
        },
        ["ammo_rifle"] = {
            displayName = "Ammo Pack (Rifle) - 30 Rounds",
            illegal = true,
            rare = false,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                AddAmmo(source, "AMMO_RIFLE", 30)
            end,
            max = 3
        },
        ["ammo_smg"] = {
            displayName = "Ammo Pack (SMG) - 30 Rounds",
            illegal = true,
            rare = false,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                AddAmmo(source, "AMMO_SMG", 30)
            end,
            max = 3
        },
        ["ammo_mg"] = {
            displayName = "Ammo Pack (MG) - 30 Rounds",
            illegal = true,
            rare = false,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                AddAmmo(source, "AMMO_MG", 30)
            end,
            max = 3
        },
        ["ammo_sniper"] = {
            displayName = "Ammo Pack (Sniper) - 30 Rounds",
            illegal = true,
            rare = false,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                AddAmmo(source, "AMMO_SNIPER", 30)
            end,
            max = 3
        },
        ["weed_bag"] = {
            displayName = "Marijuana (Bag)",
            illegal = false,
            rare = false,
            usable = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                Notification(source, "Maybe if someone's interested in ~o~this")
            end,
            max = 25
        },
        ["meth_bag"] = {
            displayName = "Meth (Bag)",
            illegal = true,
            rare = false,
            usable = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                Notification(source, "Maybe if someone's interested in ~o~this")
            end,
            max = 25
        },
        ["cocaine_bag"] = {
            displayName = "Cocaine (Bag)",
            illegal = true,
            rare = false,
            usable = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                Notification(source, "Maybe if someone's interested in ~o~this")
            end,
            max = 25
        },
    },
    weapons = {},
    weaponsData = {},
    jobs = {
        Mechanic = {},
        Legal = {},
        BeachDealer = {},
        MilitaryDealer = {},
        AsiaDealer = {},
        MafiaDealer = {},
        ExclusiveDealer = {},
    },
    properties = {},
    storages = {},
    bills = {},
    funds = {
        regular = {},
        jobs = {}
    },
    shipments = {
        Toys = {
            displayName = "Toys to cause chaos",
            job = "ExclusiveDealer",
            cost = 30000,
            items = {
                ammo_rifle = 0.3,
                ammo_smg = 0.3,
                ammo_mg = 0.3,
                ammo_sniper = 0.1
            },
            weapons = {
                WEAPON_ASSAULTRIFLE_MK2 = 0.3,
                WEAPON_MG = 0.2,
                WEAPON_ASSAULTSMG = 0.2,
                WEAPON_COMBATPDW = 0.1,
                WEAPON_SNIPERRIFLE = 0.1,
                WEAPON_MOLOTOV = 0.05,
                WEAPON_REVOLVER_MK2 = 0.05,
            },
            count = {
                items = 20,
                weapons = 20
            },
            method = {
                vehicle = true,
                model = "kalahari",
                vehicleType = "automobile",
                locations = {
                    { vector3(-174.681, -155.116, 43.0595), 69.410194396973 }
                }
            }
        },
        Ammo = {
            displayName = "Ammunition",
            jobs = {
                BeachDealer = true,
                MilitaryDealer = true,
                AsiaDealer = true,
                MafiaDealer = true
            },
            cost = 200000,
            items = {},
            weapons = {},
            count = {
                items = 12,
                weapons = 0
            },
            method = {
                vehicle = true,
                model = "bison",
                vehicleType = "automobile",
                locations = {}
            }
        },
        Shores = {
            displayName = "Mobile Arms",
            job = "BeachDealer",
            cost = 50000,
            items = {
                electronics = 1.0
            },
            weapons = {
                WEAPON_MACHINEPISTOL = 0.5,
                WEAPON_SMG = 0.1,
                WEAPON_MICROSMG = 0.3,
                WEAPON_COMPACTRIFLE = 0.1
            },
            count = {
                items = 4,
                weapons = 6
            },
            method = {
                vehicle = true,
                model = "bison",
                vehicleType = "automobile",
                locations = {
                    { vector3(-1228.254, -637.5385, 39.78923), 39.528873443604 },
                    { vector3(-1225.753, -635.7253, 39.78909), 40.03649520874 },
                    { vector3(-1220.629, -655.6896, 39.78934), 310.42840576172 },
                    { vector3(-1226.544, -669.409, 39.78952),  130.16098022461 }
                }
            }
        },
        OP = {
            displayName = "LS Port Arms",
            job = "BeachDealer",
            cost = 100000,
            attribute = "Debug",
            items = {},
            weapons = {
                WEAPON_GUSENBERG = 0.3,
                WEAPON_MICROSMG = 0.3,
                WEAPON_CARBINERIFLE_MK2 = 0.3,
                WEAPON_MG = 0.1
            },
            count = {
                items = 0,
                weapons = 10
            },
            method = {
                vehicle = true,
                model = "mesa3",
                vehicleType = "automobile",
                locations = {
                    { vector3(-1200.461, -1768.055, 3.416306), 273.76452636719 },
                    { vector3(-1194.198, -1767.643, 3.415898), 273.77209472656 }
                }
            }
        },
        MilitaryGuns = {
            displayName = "Military Weapons",
            job = "MilitaryDealer",
            cost = 400000,
            attribute = "Debug",
            items = {},
            weapons = {
                WEAPON_COMBATPDW = 0.3,
                WEAPON_TACTICALRIFLE = 0.2,
                WEAPON_GRENADE = 0.2,
                WEAPON_BATTLERIFLE = 0.1,
                WEAPON_SPECIALCARBINE = 0.1,
                WEAPON_MG = 0.1
            },
            count = {
                items = 0,
                weapons = 10
            },
            method = {
                vehicle = true,
                model = "mesa3",
                vehicleType = "automobile",
                locations = {
                    { vector3(714.2627, 2553.948, 72.59023), 177.06973266602 },
                }
            }
        }
    },
    Shipment = {
        Last = nil,
        Cooldown = 60
    },
    Environment = {
        weather = "EXTRASUNNY",
        time = {
            base = 0,
            hour = 0,
            minute = 0
        },
        CycleTimer = 0
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
                title = "",
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
    },
    Logs = {
        Reports = nil
    }
}
