Config.Jobs = {
    Mechanic = {
        displayName = "Mechanic",
        colour = "~o~",
        locations = {
            vector3(-209.8038, -1332.669, 30.89042),
            vector3(-347.3336, -133.3788, 39.00957),
            vector3(103.0328, 6615.932, 32.4352),
            vector3(1187.781, 2642.663, 38.40195)
        },
        parking = {
            {
                { vector3(-190.4847, -1290.238, 30.83279), 270.01635742188 },
                { vector3(-191.0429, -1284.489, 30.77864), 272.33221435547 },
                { vector3(-177.5311, -1357.815, 30.30955), 208.24420166016 },
                { vector3(-262.8698, -1345.853, 30.76554), 98.612297058105 }
            }
        },
        blip = {
            sprite = 446
        },
        ranks = {
            [0] = {
                displayName = "Intern"
            },
            [1] = {
                displayName = "Employee"
            },
            [2] = {
                displayName = "Boss",
                fund = true
            },
        },
        items = {
            repair_kit = {
                restrict = true
            }
        },
        weapons = {
            WEAPON_CROWBAR = {
                restrict = false
            }
        },
        vehicles = {
            bison = {
                rank = 1
            }
        },
        interiors = {
            [196609] = true,
            [234753] = true,
            [179457] = true,
            [201729] = true
        },
        defaultState = {
            active = false
        },
        billing = true
    },
    Legal = {
        displayName = "Legal Services",
        colour = "~b~",
        locations = {
            vector3(235.51, -411.3741, 48.1119)
        },
        parking = {
            {
                { vector3(263.8785, -379.354, 44.11589),  247.70501708984 },
                { vector3(258.7982, -377.3946, 44.03638), 250.98385620117 },
                { vector3(253.0873, -375.4162, 43.9127),  250.65982055664 },
                { vector3(241.4881, -371.5179, 43.7375),  251.15829467773 },
                { vector3(236.2057, -369.6609, 43.68188), 251.17471313477 },
                { vector3(230.424, -367.7496, 43.61177),  251.3215637207 }
            }
        },
        blip = {
            sprite = 498
        },
        ranks = {
            [0] = {
                displayName = "Intern"
            },
            [1] = {
                displayName = "Employee"
            },
            [2] = {
                displayName = "Boss"
            }
        },
        items = {},
        weapons = {},
        vehicles = {
            fugitive = {
                rank = 1
            }
        },
        defaultState = {},
        billing = true
    },
    BeachDealer = {
        displayName = "Shipments",
        overrideText = {
            work = "ordering"
        },
        colour = "~o~",
        locations = {
            vector3(-1147.297, -1562.163, 4.392972)
        },
        parking = {},
        shadow = true,
        ranks = {
            [0] = {
                displayName = "Dealer"
            },
            [1] = {
                displayName = "Manager"
            }
        },
        items = {},
        weapons = {},
        vehicles = {},
        defaultState = {
            last = nil,
            available = false
        },
        billing = false
    },
    MilitaryDealer = {
        displayName = "Shipments",
        overrideText = {
            work = "ordering"
        },
        colour = "~o~",
        locations = {
            vector3(980.296, 2666.659, 40.04804)
        },
        parking = {},
        shadow = true,
        ranks = {
            [0] = {
                displayName = "Dealer"
            },
            [1] = {
                displayName = "Manager"
            }
        },
        items = {},
        weapons = {},
        vehicles = {},
        defaultState = {
            last = nil,
            available = false
        },
        billing = false
    },
    AsiaDealer = {
        displayName = "Shipments",
        overrideText = {
            work = "ordering"
        },
        colour = "~o~",
        locations = {
            vector3(1897.774, 3731.938, 32.75693)
        },
        parking = {},
        shadow = true,
        ranks = {
            [0] = {
                displayName = "Dealer"
            },
            [1] = {
                displayName = "Manager"
            }
        },
        items = {},
        weapons = {},
        vehicles = {},
        defaultState = {
            last = nil,
            available = false
        },
        billing = false
    },
    MafiaDealer = {
        displayName = "Shipments",
        overrideText = {
            work = "ordering"
        },
        colour = "~o~",
        locations = {
            vector3(-309.9734, 6272.378, 31.49231)
        },
        parking = {},
        shadow = true,
        ranks = {
            [0] = {
                displayName = "Dealer"
            },
            [1] = {
                displayName = "Manager"
            }
        },
        items = {},
        weapons = {},
        vehicles = {},
        defaultState = {
            last = nil,
            available = false
        },
        billing = false
    },
    ExclusiveDealer = {
        displayName = "Shipments",
        overrideText = {
            work = "ordering"
        },
        blip = {
            sprite = 888,
            colour = 12
        },
        colour = "~o~",
        locations = {
            vector3(-153.4369, -160.1485, 43.62131)
        },
        parking = {},
        shadow = true,
        ranks = {
            [0] = {
                displayName = "Dealer"
            }
        },
        items = {},
        weapons = {},
        vehicles = {},
        defaultState = {
            last = nil,
            available = false
        },
        billing = false
    }
}
