Config.Jobs = {
    Mechanic = {
        displayName = "Mechanic",
        colour = "~o~",
        locations = {
            vector3(-209.8038, -1332.669, 30.89042),
            vector3(-347.3336, -133.3788, 39.00957)
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
                displayName = "Boss"
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
            [234753] = true
        },
        defaultState = {
            active = false
        },
        billing = true
    }
}
